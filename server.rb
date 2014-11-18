require 'sinatra'
require 'mongo'
require 'pry'
require './build_loader.rb'

get '/' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  @builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds").find
  erb :index
end

get '/new_build' do
  erb :new_build
end

post '/new_build' do
  BuildLoader.load_build(params[:name], params[:url])
  redirect :index
end

get '/info/:id' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
  @build = builds.find({"_id" => BSON::ObjectId(params["id"])}).first
  erb :info
end

get '/info' do
  erb :info
end

get '/insert_crap' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
  build = {name: 'crap'}
  builds.insert(build)
end
