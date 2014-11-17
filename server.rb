require 'sinatra'
require 'mongo'
require 'pry'

get '/' do
  mongo_uri = ENV['MONGOLAB_URI'] | "localhost"
  #@builds = Mongo::MongoClient.from_uri(mongo_uri).db("collective").collection("builds").find
  @build = []
  erb :index
end
