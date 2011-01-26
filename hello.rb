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
  contact = params[:contact]
  contact_type = contact.start_with?("@") ||
                 !contact.include?("@") ? "twitter" : "email"

  doc = {
    "contact" => contact,
    "type"    => contact_type,
    "referer" => params[:referer],
  }
   
  $collection.insert(doc)
  {"success" => true}.to_json
end
