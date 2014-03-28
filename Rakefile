require 'tilt'
require 'slim'
require 'redcarpet'
require 'yaml'

Slim::Engine.set_default_options pretty: true

SKILLS = YAML::load_file("./skills.yaml")

def render_skills(key)
  output = "<ul class=\"skills\">"
  SKILLS[key.to_s].each do |skill, ability|
    output << "<li><span class=\"name\">#{skill}</span><div class=\"meter\"><span style=\"width: #{ability*10}%\"></span></span></li>"
  end
  output << "</ul>"
  output
end

desc "Render the page"
task :render => ["index.html", 'css/main.css']

file "index.html" => ["resume.mkd", "layout.slim", __FILE__, "skills.yaml"] do
  layout = Tilt.new('layout.slim')
  template = Tilt.new('resume.mkd')

  content = layout.render(self)

  File.open("index.html", "w") { |f| f.write(content) }
end

file "css/main.css" => "css/main.scss" do
  `compass compile css/main.scss`
end
