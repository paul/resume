require 'slim'
require 'tilt'
require 'redcarpet'


mkd_renderer_opts = {
  with_toc_data: true
}
mkd_renderer = Redcarpet::Render::HTML.new(mkd_renderer_opts)

mkd_extensions = {
  no_intra_emphasis: true,
  lax_spacing: true,
  highlight: true
}

Slim::Engine.set_default_options pretty: true
Slim::Embedded.set_default_options markdown: mkd_extensions

Tilt.register Tilt::RedcarpetTemplate::Redcarpet2, 'markdown', 'mkd', 'md'
Tilt.prefer Tilt::RedcarpetTemplate::Redcarpet2, 'markdown'

desc "Render the page"
task :render => ["index.html", 'css/main.css']

file "index.html" => ["resume.mkd", "layout.slim", __FILE__] do
  layout = Tilt.new('layout.slim')
  # template = Tilt.new('resume.mkd')
  # Tilt won't let me pass the right options to redcarpet
  mkd = Redcarpet::Markdown.new(mkd_renderer, mkd_extensions)

  content = layout.render { mkd.render(File.read("resume.mkd")) }

  File.open("index.html", "w") { |f| f.write(content) }
end

file "css/main.css" => "css/main.scss" do
  `compass compile css/main.scss`
end
