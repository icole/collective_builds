require 'sinatra'
require 'mongo'
require 'pry'
require './build_loader.rb'

get '/' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  @builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds").find
  erb :index, :layout => :application
end

get '/new_build' do
  erb :new_build, :layout => :application
end

post '/new_build' do
  BuildLoader.load_build(params[:name], params[:url])
  redirect '/'
end

get '/info/:id' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
  @build = builds.find({"_id" => BSON::ObjectId(params["id"])}).first
  erb :info, :layout => :application
end

get '/insert_crap' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
  BuildLoader.load_build('Test Build', 'http://pcpartpicker.com/p/q2mcNG')
  redirect '/'
end
