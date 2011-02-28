require 'rubygems'
require 'sinatra/base'
require 'uri'
require 'mongo'
require 'erb'
require 'json'
require 'sinatra/content_for'
require 'models/book'
require 'models/contact'

class String
  def slugify
    returning self.downcase.gsub(/'/, '').gsub(/[^a-z0-9]+/, '-') do |slug|
      slug.chop! if slug.last == '-'
    end
  end
end

class Bibliotechnical < Sinatra::Base
  set :static, true
  set :public, 'public'

  helpers Sinatra::ContentFor

  configure do
    uri = URI.parse(ENV['MONGOHQ_URL'])
    MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
    MongoMapper.database = uri.path.gsub(/^\//, '')
  end
    
  get '/' do
    erb :index, :layout => false
  end

  get '/books/:slug' do
    @book = Book.where(:slug => params[:slug]).first
    unless @book.nil? 
      erb :listing
    else
      erb :bt404
    end
  end

  post '/subscribe' do
    content_type :json
    contact = params[:contact]
    contact_type = contact.start_with?("@") ||
                  !contact.include?("@") ? "Twitter" : "email"

    record = Contact.create({
      :contact => contact,
      :type    => contact_type,
      :referer => request.referer
    })
    record.save
   
    {"success" => true, "type" => record.type}.to_json
  end

  not_found do
    erb :bt404
  end
end
