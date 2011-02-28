require 'mongo_mapper'

class Contact
  include MongoMapper::Document
  key :contact, String
  key :type, String
  key :referer, String
end

