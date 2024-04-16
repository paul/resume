# frozen_string_literal: true

require "date"

require "slim"
require "redcarpet"
require "nokogiri"
require "ap"

class ResumeScope
  def initialize(html)
    @doc = Nokogiri::HTML5.fragment(html)
  end

  def header
    nodes = Nokogiri::XML::NodeSet.new(Nokogiri::HTML5::Document.new)
    @doc.children.each do |node|
      if node["id"] == "achievements"
        break
      end

      nodes << node
    end
    nodes.to_html
  end

  def achievements
    achievements = []
    node = @doc.at_css("#achievements")
    achievement = nil
    while node = node.next
      next if node.blank?
      break if node.name == "h2"

      if node.name == "h3"
        achievements << achievement if achievement
        achievement = Achievement.new(node)
      else
        achievement << node
      end
    end

    achievements << achievement

    achievements
  end

  class Achievement
    def initialize(header)
      @header = header
      @type, @title, @company, @date = *header.children
      @content = Nokogiri::XML::NodeSet.new(Nokogiri::HTML5::Document.new)
    end

    def type
      case @type.inner_text.strip
      when /Employment/ then "job"
      when /Presentation/ then "talk"
      when /Open Source/ then "oss"
      end
    end

    def start_date
      text = @date.inner_text
      text = text.split("-").first.strip
      time_el(text)
    end

    def end_date
      text = @date.inner_text
      return unless text.include?("-")

      text = text.split(" - ").last.strip
      time_el(text)
    end

    def title
      @title&.inner_text
    end

    def company
      @company&.inner_text
    end

    def content
      @content.to_html
    end

    def <<(node)
      @content << node
    end

    def time_el(time)
      case time
      when "Present"
        %{<time datetime="#{Date.today.year}">Present</time>}
      when /\A\d{4}\Z/
        date = Date.strptime(time, "%Y")
        %{<time datetime="#{date.strftime('%Y')}">#{date.strftime('%Y')}</time>}
      else
        date = Date.strptime(time, "%b %Y")
        %{<time datetime="#{date.strftime('%Y-%m')}">#{date.strftime('%b %Y')}</time>}
      end
    end
  end
end

mkd_renderer_opts = {
  with_toc_data: true
}
mkd_renderer = Redcarpet::Render::HTML.new(mkd_renderer_opts)

mkd_extensions = {
  no_intra_emphasis: true,
  lax_spacing: true,
  highlight: true
}

Slim::Engine.set_options pretty: true
Slim::Embedded.set_options markdown: mkd_extensions

desc "Render the page"
task render: [
  "gh-pages/index.html",
  "gh-pages/css/main.css",
  "gh-pages/Resume of Paul Sadauskas.pdf"
]

file "gh-pages/index.html" => ["resume.mkd", "layout.slim", __FILE__] do
  layout = Tilt.new("layout.slim")
  # template = Tilt.new('resume.mkd')
  # Tilt won't let me pass the right options to redcarpet
  mkd = Redcarpet::Markdown.new(mkd_renderer, mkd_extensions)
  html = mkd.render(File.read("resume.mkd"))

  scope = ResumeScope.new(html)

  content = layout.render(scope)

  File.open("gh-pages/index.html", "w") { |f| f.write(content) }
end

file "gh-pages/Resume of Paul Sadauskas.pdf" => ["gh-pages/index.html", "gh-pages/css/main.css", __FILE__] do
  sh(
    "wkhtmltopdf",
    "--enable-local-file-access",
    "--enable-external-links",
    "--log-level", "info",
    "--zoom", "0.8",
    "gh-pages/index.html",
    "gh-pages/Resume of Paul Sadauskas.pdf"
  )
end

file "gh-pages/css/main.css" => "css/main.scss" do
  sh("sassc", "css/main.scss", "gh-pages/css/main.css")
end

file "gh-pages/css/print.css" => "css/print.scss" do
  sh("sassc", "css/print.scss", "gh-pages/css/print.css")
end

webfonts = "gh-pages/css/webfonts"
directory webfonts
file webfonts do
  cp Dir["css/fontawesome/webfonts/*"], webfonts
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
