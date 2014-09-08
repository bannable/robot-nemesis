require './models/setup.rb'
require 'sinatra'
require 'sinatra/redirect_with_flash'
require 'rack-flash'

SITE_TITLE = "Salts"
SITE_DESCRIPTION = "The Salt Must Flow"

set :session_secret, CONFIG['session_secret']
enable :sessions

set :port, CONFIG['port']
set :bind, CONFIG['bind']
set :run, true

use Rack::Flash, :sweep => true

get '/' do
	if ($active_match)
		erb :home_active
	else
		erb :home_inactive
	end
end
