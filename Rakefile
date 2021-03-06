# frozen_string_literal: true

require "slim"
require "redcarpet"

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

desc "Render the page"
task render: ["gh-pages/index.html", "gh-pages/css/main.css"]

desc "Render the CV"
task render_cv: ["cv-pages/index.html", "cv-pages/css/main.css"]

file "gh-pages/index.html" => ["resume.mkd", "layout.slim", __FILE__] do
  layout = Tilt.new("layout.slim")
  # template = Tilt.new('resume.mkd')
  # Tilt won't let me pass the right options to redcarpet
  mkd = Redcarpet::Markdown.new(mkd_renderer, mkd_extensions)

  content = layout.render { mkd.render(File.read("resume.mkd")) }

  File.open("gh-pages/index.html", "w") { |f| f.write(content) }
end

file "cv-pages/index.html" => ["cv.mkd", "layout.slim", __FILE__] do
  layout = Tilt.new("layout.slim")
  # template = Tilt.new('resume.mkd')
  # Tilt won't let me pass the right options to redcarpet
  mkd = Redcarpet::Markdown.new(mkd_renderer, mkd_extensions)

  content = layout.render { mkd.render(File.read("cv.mkd")) }

  File.open("cv-pages/index.html", "w") { |f| f.write(content) }
end

file "gh-pages/css/main.css" => "css/main.scss" do
  `compass compile --sass-dir css --css-dir gh-pages/css`
end

file "cv-pages/css/main.css" => "css/main.scss" do
  `compass compile --sass-dir css --css-dir cv-pages/css`
end

desc "Publish to resume.sadauskas.com"
task :publish do
  FileUtils.cd "gh-pages" do
    `git commit -am "Re-render" && git push`
  end
end
