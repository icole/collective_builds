require 'sinatra'
require 'mongo'
require 'pry'

Dir[".//lib/*.rb"].each {|file| require file }

before do
  mongo_uri = ENV['MONGOLAB_URI']
  db_name = 'collective_builds'
  @builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
end


helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'commun1$m']
  end
end

get '/review_builds' do
  protected!
  @builds = @builds.find({reviewed: false})
  erb :review, :layout => :application
end

get '/' do
  @gaming = @builds.find({reviewed: true, category: "Gaming"})
  @media = @builds.find({reviewed: true, category: "Media"})
  @performance = @builds.find({reviewed: true, category: "Performance"})
  @hackintosh = @builds.find({reviewed: true, category: "Hackintosh"})
  @mini = @builds.find({reviewed: true, category: "Mini PC"})
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
  @build = @builds.find({"_id" => BSON::ObjectId(params["id"])}).first
  if @build["parts"]
    erb :info, :layout => :application
  else
    redirect '/'
  end
end

get '/build_guide' do
  send_file "./files/build_guide_v01.pdf", :filename => "Build_Guide_V01.pdf", :type => 'Application/octet-stream'
end
