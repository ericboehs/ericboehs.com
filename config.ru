require 'bundler/setup'
require 'rack/contrib'
require 'rack/contrib/try_static'

use Rack::ResponseHeaders do |headers|
  headers['Content-Type'] = 'text/html; charset=utf-8' if headers['Content-Type'] == 'text/html'
end
use Rack::Deflater
use Rack::StaticCache, urls: ["/images", "/stylesheets", "/javascripts", "/fonts"], root: "build"
use Rack::TryStatic, root: "build", urls: ["/"], try: [".html", "index.html", "/index.html"]

run lambda { |env|
  not_found_page = File.expand_path("../build/404.html", __FILE__)
  not_found_content = File.exist?(not_found_page) ? File.read(not_found_page) : '404 - Page not found'
  [ 404, { 'Content-Type'  => 'text/html' }, [not_found_content] ]
}
