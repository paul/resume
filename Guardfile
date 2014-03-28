# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rake, task: :render do
  watch("layout.slim")
  watch("resume.mkd")
  watch("css/main.scss")
end

guard 'livereload' do
  watch("index.html")
  watch("css/main.scss")
end

