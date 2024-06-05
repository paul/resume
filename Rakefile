# frozen_string_literal: true

require "date"
require "ostruct"

require "slim"
require "kramdown"
require "nokogiri"

require "ap"
require "debug"

class ResumeScope
  attr_reader :hero, :contact, :sections

  def initialize(html)
    @doc = Nokogiri::HTML5.fragment(html)
    sections = []
    section = nil
    @doc.children.each do |node|
      if node.name == "h1"
        sections << section
        section = Section.new(node)
      else
        section << node
      end
    end
    sections << section
    @hero, @contact, *@sections = *sections.compact
  end

  class Section
    attr_reader :id, :nodes, :achievements

    def initialize(node)
      @id = node["id"]
      @title = node
      @content = Nokogiri::XML::NodeSet.new(Nokogiri::HTML5::Document.new)
      @achievements = []
    end

    def <<(node)
      if node.name == "h2" && @id != "hero"
        @achievements << Achievement.new(node)
      elsif ach = @achievements.last
        ach << node
      else
        @content << node
      end
    end

    def title
      @title.to_html
    end

    def content
      @content.to_html
    end

    # Used by the hero and contact sections, to just render them
    def to_html
      Nokogiri::XML::NodeSet.new(Nokogiri::HTML5::Document.new).tap do |ns|
        ns << @title
        @content.each { |node| ns << node }
      end.to_html
    end
    alias_method :to_s, :to_html
  end

  class Achievement
    attr_reader :title, :company

    def initialize(header)
      @content = Nokogiri::XML::NodeSet.new(Nokogiri::HTML5::Document.new)
      @title, @company, @date = header.children.map { |node| node.text.strip }
    end

    def <<(node)
      @content << node
    end

    def content
      @content.to_html
    end

    def type
      "job"
      # case @type.inner_text.strip
      # when /Employment/ then "job"
      # when /Presentation/ then "talk"
      # when /Open Source/ then "oss"
      # end
    end

    def start_date
      text = @date
      text = text.split("-").first.strip
      time_el(text)
    end

    def end_date
      text = @date
      return unless text.include?("-")

      text = text.split(" - ").last.strip
      time_el(text)
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

Slim::Engine.set_options pretty: true

desc "Render the page"
task render: [
  "gh-pages/index.html",
  "gh-pages/css/main.css",
  "gh-pages/Resume of Paul Sadauskas.pdf"
]

file "gh-pages/index.html" => ["resume.mkd", "layout.slim", __FILE__] do
  layout = Tilt.new("layout.slim")
  # doc = Commonmarker.parse(File.read("resume.mkd"))
  doc = Kramdown::Document.new(File.read("resume.mkd"))
  scope = ResumeScope.new(doc.to_html)

  content = layout.render(scope)

  File.write("gh-pages/index.html", content)
end

file "gh-pages/Resume of Paul Sadauskas.pdf" => ["gh-pages/index.html", "gh-pages/css/main.css", __FILE__] do
  # sh(
  #   "podman",
  #   "run",
  #   "-v", "./gh-pages:/tmp/gh-pages:rw,Z,U",
  #   "ghcr.io/surnet/alpine-wkhtmltopdf:3.20.0-0.12.6-full",
  sh(
    "wkhtmltopdf",
    "--enable-local-file-access",
    "--enable-external-links",
    "--log-level", "info",
    "--zoom", "0.7",
    "./gh-pages/index.html",
    "./gh-pages/Resume of Paul Sadauskas.pdf"
  )
end

file "gh-pages/css/main.css" => "css/main.scss" do
  sh("dartsass", "css/main.scss", "gh-pages/css/main.css")
end

file "gh-pages/css/print.css" => "css/print.scss" do
  sh("dartsass", "css/print.scss", "gh-pages/css/print.css")
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
