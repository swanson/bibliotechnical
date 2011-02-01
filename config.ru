require 'bibliotechnical'

use Rack::Static, :urls => ["/blog"]

run Bibliotechnical
