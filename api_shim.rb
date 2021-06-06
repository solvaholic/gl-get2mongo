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
  json "{'key' => 'BLAH', 'value' => 'READ'}"
end

# GET to Update
get '/update/' do
  json "{'key' => 'BLAH', 'value' => 'UPDATED'}"
end

# GET to Delete
get '/delete/' do
  json "{'key' => 'BLAH', 'value' => 'DELETED'}"
end

# Define healthcheck endpoint
get '/status' do
  'OK'
end
