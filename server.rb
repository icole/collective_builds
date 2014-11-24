require 'sinatra'
require 'mongo'
require 'pry'

Dir[".//lib/*.rb"].each {|file| require file }

get '/' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  @builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds").find({reviewed: true})
  erb :index, :layout => :application
end

get '/new_build' do
  erb :new_build, :layout => :application
end

post '/new_build' do
  build_id = BuildLoader.load_build(params)
  redirect "/info/#{build_id.to_s}"
end

get '/info/:id' do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
  builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
  @build = builds.find({"_id" => BSON::ObjectId(params["id"])}).first
  if @build["parts"]
    erb :info, :layout => :application
  else
    redirect '/'
  end
end

get '/build_guide' do
  send_file "./files/build_guide_v01.pdf", :filename => "Build_Guide_V01.pdf", :type => 'Application/octet-stream'
end
