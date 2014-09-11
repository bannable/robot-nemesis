require './models/setup.rb'
require 'sinatra'
require 'sinatra/redirect_with_flash'
require 'rack-flash'

SITE_TITLE = "Salts"
SITE_DESCRIPTION = "The Salt Must Flow"

set :session_secret, CONFIG['session_secret']
enable :sessions

if (!DEVELOPMENT)
	disable :logging
end

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

post "/update" do
	content_type 'application/json'
	if ($active_match)
		red = $active_red
		blue = $active_blue
		rvic = red.matches.all(:victor => red).count
		{
			:active => true,
			:red_name => red.name,
			:red_rating => red.rating,
			:red_expected => $rating_red.expected,
			:red_provisional => red.provisional?,
			:red_wins => red.matches.all(:victor => red).count,
			:red_matches => red.matches.all.count,
			:blue_name => blue.name,
			:blue_rating => blue.rating,
			:blue_expected => $rating_blue.expected,
			:blue_provisional => blue.provisional?,
			:blue_wins => blue.matches.all(:victor => blue).count
		}.to_json
	else
		{
			:active => false
		}.to_json
	end
end
