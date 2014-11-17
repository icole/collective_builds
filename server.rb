require 'sinatra'
require 'mongo'
require 'pry'

get '/' do
  @builds = Mongo::MongoClient.new("localhost", 27017).db("collective").collection("builds").find
  erb :index
end
