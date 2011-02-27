require '../models/book'
require 'mongo'
require 'uri'
require 'json'

class Bootstrap
  def self.from_uri(uri_string)
    uri = URI.parse(uri_string)
    conn = Mongo::Connection.from_uri(uri_string)
    db = conn.db(uri.path.gsub(/^\//, ''))
    books = db.collection("books")

    Dir.glob('../data/*.json') do |item|
      puts item
      File.open(item,'r') do |file|
        model = Book.from_json(file.readlines.to_s)
        books.update({'slug' => model.slug}, model.to_mongo, {:upsert => true})
      end
    end
  end
end
