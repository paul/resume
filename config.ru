# frozen_string_literal: true

require "rack-livereload"

use Rack::LiveReload
use Rack::Static, urls: ["/"], index: "index.html", root: "gh-pages"

run lambda { |_env|
  [
    200,
    {
      "Content-Type" => "text/html",
      "Cache-Control" => "public, max-age=86400"
    },
    File.open("gh-pages/index.html", File::RDONLY)
  ]
}
