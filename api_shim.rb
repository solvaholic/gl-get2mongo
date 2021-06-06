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

# Define the database collection
def collection
  client = Mongo::Client.new('mongodb://mongo:27017/solvahol')
  client[:get2mongo]
end

# Say explicitly where to listen
set :bind, '0.0.0.0'
set :port, 4567

# GET to Create
get '/create/' do
  json "{'key' => 'BLAH', 'value' => 'CREATED'}"
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
