require './models/setup.rb'
require 'sinatra'
require 'sinatra/redirect_with_flash'
require 'rack-flash'

SITE_TITLE = "Salts"
SITE_DESCRIPTION = "The Salt Must Flow"

enable :sessions

set :port, CONFIG['port']
set :bind, CONFIG['bind']
set :environment, :development
set :run, true

use Rack::Flash, :sweep => true

get '/' do
	erb :home
end
