require 'sinatra'
require 'mongo'
require 'pry'

get '/' do
  mongo_uri = ENV['MONGOLAB_URI']
  @builds = Mongo::MongoClient.from_uri(mongo_uri).db("collective").collection("builds").find
  erb :index
end
