set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

Time.zone = "UTC"

page "/feed.xml", layout: false

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :automatic_image_sizes
end

activate :blog do |blog|
  blog.sources = ":year-:month-:day-:title.html"
  blog.permalink = ":year/:month/:day/:title"
end

activate :directory_indexes
activate :gzip
