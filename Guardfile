# frozen_string_literal: true

guard :rake, task: :render do
  watch "layout.slim"
  watch "resume.mkd"
  watch "css/main.scss"
end

guard "livereload" do
  watch "gh-pages/index.html"
  watch "gh-pages/css/main.scss"
end
