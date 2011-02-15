require 'rubygems'
require 'sinatra/base'
require 'uri'
require 'mongo'
require 'erb'
require 'json'

class Bibliotechnical < Sinatra::Base
  set :static, true
  set :public, 'public'

  configure do
    uri = URI.parse(ENV['MONGOHQ_URL'])
    conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
    db = conn.db(uri.path.gsub(/^\//, ''))
    $collection = db.collection("contacts")
  end
    
  get '/' do
    erb :index
  end

  get '/browse' do
    erb :browse
  end

  class Book
    attr_accessor :title, :author, :publisher, :edition, :year, :isbn
    attr_accessor :abstract, :tags, :posts

    def initialize
      self.tags = []
      self.posts = []
    end
  end

  class Post
    attr_accessor :source_url, :source_title
    attr_accessor :quotes

    def initialize
      self.quotes = []
    end
  end

  class Quote
    attr_accessor :body, :user, :url
  end

  get '/listing' do
    @book = Book.new
    @book.title = "Learning Python"
    @book.author = "Mark Lutz"
    @book.publisher = "O'Reilly"
    @book.edition = "Fourth Edition"
    @book.year = 2009
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
        q = Quote.new
        q.body = body
        q.user = quote_users[index]
        q.url = quote_urls[index]
        hn.quotes << q
    end
    @book.posts << hn
    @book.posts << hn
    @book.posts << hn
    @book.posts << hn
    @book.posts << hn

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
end
