require 'rubygems'
require 'sinatra/base'
require 'uri'
require 'mongo'
require 'erb'
require 'json'
require 'mongo_mapper'

class Book
  include MongoMapper::Document
  key :title, String
  key :author, String
  key :publisher, String
  key :edition, String
  key :year, String
  key :isbn, String
  key :abstract, String
  key :tags, Array
  many :posts

  key :slug, String

  key :skill, Integer
  key :life, Integer
  key :approach, Integer
  key :style, Integer
end

class Post
  include MongoMapper::EmbeddedDocument
  key :source_url, String
  key :source_title, String
  many :quotes

end

class Quote
  include MongoMapper::EmbeddedDocument
  key :body, String
  key :user, String
  key :url, String

end

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

  configure do
    uri = URI.parse(ENV['MONGOHQ_URL'])
    conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
    db = conn.db(uri.path.gsub(/^\//, ''))
    $collection = db.collection("contacts")
    MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
    MongoMapper.database = uri.path.gsub(/^\//, '')
  end
    
  get '/' do
    erb :index
  end

  get '/books/:slug' do
    @book = Book.where(:slug => params[:slug]).first
    unless @book.nil? 
      erb :listing
    else
      erb :bt404
    end
  end
 
  get '/listing' do
    @book = Book.new
    @book.title = "Learning Python"
    @book.slug = @book.title.slugify
    @book.author = "Mark Lutz"
    @book.publisher = "O'Reilly"
    @book.edition = "Fourth Edition"
    @book.year = 2009
    @book.skill = 20
    @book.style = 30
    @book.approach = 85
    @book.life = 50
    @book.abstract = "
        Designed to be an in-depth introduction to the core Python language, 
        <i>Learning Python</i> has the feel of a self-paced class on Python
        fundamentals.<br/><br/> With material for both Python 2.X and 3.X, this book is 
        a perfect introduction to the language.
      "
    @book.isbn = "0596158068"
    @book.tags << "python"
    @book.tags << "learning"
    hn = Post.new
    hn.source_url = "http://news.ycombinator.com/item?id=121779"
    hn.source_title = "Ask YC: What is the best Python book for a beginner?"
    quote_bodies = ["Learning Python is an excellent book. It is what I found 
                    most useful for learning the language. I bought and read 
                    many books, and this one is the best I found.",
                    "I started learning Python from a Mark Lutz seminar actually. 
                    He is a great teacher.",
                    "If you really want a beginner book, Learning Python is a great choice."]
    quote_users = ["mathogre", "ivankirigin", "fireandfury"]
    quote_urls = ["http://news.ycombinator.com/item?id=121994",
                  "http://news.ycombinator.com/item?id=121827",
                  "http://news.ycombinator.com/item?id=121881"]
    quote_bodies.each_with_index do |body, index|
        q = Quote.new(:body => body, 
                               :user => quote_users[index],
                               :url  => quote_urls[index])
        hn.quotes << q
    end
    @book.posts << hn

    @book.save
    puts @book.new?
    erb :listing
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

  not_found do
    erb :bt404
  end
end
