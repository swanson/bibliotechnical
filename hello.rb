require 'rubygems'
require 'sinatra'
require 'uri'
require 'mongo'
require 'erb'
require 'json'

configure do
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  db = conn.db(uri.path.gsub(/^\//, ''))
  $collection = db.collection("contacts")
end

get '/' do
  erb :index
end

post '/subscribe' do
  content_type :json
  contact = params[:contact]
  contact_type = contact.start_with?("@") ||
                 !contact.include?("@") ? "Twitter" : "email"

  doc = {
    "contact" => contact,
    "type"    => contact_type,
    "referer" => params[:referer],
  }
   
  $collection.insert(doc)
  {"success" => true, "type" => contact_type}.to_json
end
