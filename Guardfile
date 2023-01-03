# frozen_string_literal: true

guard :rake, task: "gh-pages/index.html" do
  watch "layout.slim"
  watch "resume.mkd"
end

guard :rake, task: "gh-pages/css/main.css" do
  watch "css/main.scss"
end

guard "livereload" do
  watch "gh-pages/index.html"
  watch "gh-pages/css/main.scss"
end
