
begin
  require 'webby'
rescue LoadError
  require 'rubygems'
  require 'webby'
end

SITE = Webby.site

SITE.host = 'theamazingrando.com'
SITE.remote_dir = '/srv/www/sadauskas.us/htdocs'

# Load the other rake files in the tasks folder
Dir.glob('tasks/*.rake').sort.each {|fn| import fn}

# EOF
