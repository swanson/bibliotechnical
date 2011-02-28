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
  many :posts, :class_name => 'Post'
  many :related, :class_name => 'RelatedBook'

  key :slug, String

  key :skill, Integer
  key :life, Integer
  key :approach, Integer
  key :style, Integer

  key :alt_preview, String
end

class Post
  include MongoMapper::EmbeddedDocument
  key :source_url, String
  key :source_title, String
  many :quotes, :class_name => 'Quote'
end

class Quote
  include MongoMapper::EmbeddedDocument
  key :body, String
  key :user, String
  key :url, String
end

class RelatedBook
  include MongoMapper::EmbeddedDocument
  key :slug, String
  key :reason, String
end

