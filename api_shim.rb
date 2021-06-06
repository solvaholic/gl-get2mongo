# This is an API shim to work around missing write capability in
# Graylog's CSV and HTTP JSONPath lookup table data adapters.
# 
# This application listens for HTTP GET requests like:
#   GET /<verb>/?key=<blob>
# 
# <verb> can be create, remove, update, or delete, and <blob>
# must be a URL encoded JSON object.
# 
# <blob> must include "key", and may include "value":
#   { "key": "<string>",
#     "value": "<string>"}
# 
# This API shim will perform <verb> request in MongoDB,
# using details provided in <blob>.
# 
# Prerequisites:
# - gem install sinatra webrick mongo
# - MongoDB is available at mongo:27017

require 'sinatra'
require 'json'
require 'mongo'

# Define output function
def json data_object
  content_type :json
  data_object.to_json
end

# Say explicitly where to listen
set :bind, '0.0.0.0'
set :port, 4567

# GET to Create
get '/create/' do
  obj = JSON.parse( CGI.unescape( params['key'].to_str ) )
  client = Mongo::Client.new('mongodb://mongo:27017/solvahol')
  collection = client[:get2mongo]
  # Create requires key and value
  unless obj['key'] && obj['value']
    # Didn't receive required params, return Bad Request
    status 400
    return json obj
  end
  # Don't create document if key exists
  if collection.find( { :key => obj['key'] } ).count > 0
    # Document with this key already exists, return Conflict
    status 409
    return json obj
  end
  # Attempt to create the document
  doc = { key: obj['key'], value: obj['value'] }
  if collection.insert_one( doc ).n == 1
    # One document was created or updated, return OK
    status 200
    return json obj
  else
    # Something went wrong, return Internal Server Error
    status 500
    return json obj
  end
end

# GET to Read
get '/read/' do
  obj = JSON.parse( CGI.unescape( params['key'].to_str ) )
  client = Mongo::Client.new('mongodb://mongo:27017/solvahol')
  collection = client[:get2mongo]
  # Read requires key
  unless obj['key']
    # Didn't receive required param, return Bad Request
    status 400
    return json obj
  end
  # Attempt to read the document
  doc = collection.find(:key => obj['key']).first
  if doc == nil
    # Document was not found, return Not Found
    status 404
    return json obj
  elsif doc['key'] == obj['key']
    # Document was found, return OK
    status 200
    return json doc
  else
    # Something went wrong, return Internal Server Error
    status 500
    return json obj
  end
end

# GET to Update
get '/update/' do
  obj = JSON.parse( CGI.unescape( params['key'].to_str ) )
  client = Mongo::Client.new('mongodb://mongo:27017/solvahol')
  collection = client[:get2mongo]
  # Update requires key and value
  unless obj['key'] && obj['value']
    # Didn't receive required params, return Bad Request
    status 400
    return json obj
  end
  # Attempt to update the document
  doc = { key: obj['key'], value: obj['value'] }
  result = collection.find_one_and_update(
    { :key => doc[:key] },
    { '$set' => doc },
    { upsert: true } )
  if result == nil
    # Document was created, return OK
    status 200
  elsif result['key'] == doc[:key]
    # Document was updated, return OK
    status 200
  else
    # Something went wrong, return Internal Server Error
    status 500
  end
  return json obj
end

# GET to Delete
get '/delete/' do
  obj = JSON.parse( CGI.unescape( params['key'].to_str ) )
  client = Mongo::Client.new('mongodb://mongo:27017/solvahol')
  collection = client[:get2mongo]
  # Delete requires key
  unless obj['key']
    # Didn't receive required param, return Bad Request
    status 400
    return json obj
  end
  # Attempt to delete the document
  result = collection.find(:key => obj['key'])
  if result.count == 0
    # Document was not found, return Not Found
    status 404
    return json obj
  elsif result.delete_one.deleted_count == 1
    # Document was deleted, return OK
    status 200
    return json obj
  else
    # Something went wrong, return Internal Server Error
    status 500
    return json obj
  end
end

# Define healthcheck endpoint
get '/status' do
  'OK'
end
