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
task render: ["gh-pages/index.html", "gh-pages/css/main.css", "gh-pages/Resume of Paul Sadauskas.pdf"]

file "gh-pages/index.html" => ["resume.mkd", "layout.slim", __FILE__] do
  layout = Tilt.new("layout.slim")
  # template = Tilt.new('resume.mkd')
  # Tilt won't let me pass the right options to redcarpet
  mkd = Redcarpet::Markdown.new(mkd_renderer, mkd_extensions)

  content = layout.render { mkd.render(File.read("resume.mkd")) }

  File.open("gh-pages/index.html", "w") { |f| f.write(content) }
end

file "gh-pages/Resume of Paul Sadauskas.pdf" => ["gh-pages/index.html", __FILE__] do
  sh(
    "wkhtmltopdf",
    "--enable-local-file-access",
    "--enable-external-links",
    "--log-level", "info",
    "gh-pages/index.html",
    "gh-pages/Resume of Paul Sadauskas.pdf"
  )
end

file "gh-pages/css/main.css" => "css/main.scss" do
  sh("sassc", "css/main.scss", "gh-pages/css/main.css")
end

letters = Rake::FileList.new("letters/*.mkd")
letters.each do |source|
  target = source.ext("pdf")
  desc "Render #{source} to pdf"
  file target => source do
    sh(
      "pandoc",
      "-s",
      "-f",
      # "markdown+smart",
      "markdown_strict+pipe_tables+backtick_code_blocks+auto_identifiers+yaml_metadata_block+implicit_figures+table_captions+footnotes+smart+escaped_line_breaks+header_attributes",
      # "--template", "template-letter.tex",
      "--template", "eisvogel_mod.latex",
      # "--toc",
      # "--listings",
      "--columns=72",
      # "--number-sections",
      "--pdf-engine", "xelatex",
      "--dpi=300",
      "-V", "geometry=left=2.54cm,right=2.54cm,top=1.91cm,bottom=1.91cm",
      "-V", "header-includes=\\pagenumbering{gobble}",
      "-o", target,
      source
    )
  end
end

desc "Publish to resume.sadauskas.com"
task :publish do
  FileUtils.cd "gh-pages" do
    `git commit -am "Re-render" && git push`
  end
end
