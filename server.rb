require 'sinatra'

set :views, settings.root

get '/' do
  markdown :resume, layout: :layout, layout_engine: :erb
end

