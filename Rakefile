require 'tilt'
require 'slim'
require 'redcarpet'

Slim::Engine.set_default_options pretty: true

desc "Render the page"
task :render => "index.html"

file "index.html" => ["resume.mkd", "layout.slim"] do
  layout = Tilt.new('layout.slim')
  template = Tilt.new('resume.mkd')

  content = layout.render { template.render }

  File.open("index.html", "w") { |f| f.write(content) }
end
