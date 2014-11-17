require 'sinatra'
require 'mongo'
require 'pry'

get '/' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  @builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds").find
  erb :index
end

get '/insert_crap' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
  build = {name: 'crap'}
  builds.insert(build)
end
