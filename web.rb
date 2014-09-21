require './models/setup.rb'
require 'sinatra'
require 'sinatra/redirect_with_flash'
require 'rack-flash'

if (!DEVELOPMENT)
	set :environment, :production
	disable :logging
	SITE_TITLE = "The Salt Advisor"
	SITE_DESCRIPTION = "The Salt Must Flow"
else
	require 'sinatra/reloader'
	set :environment, :development
	SITE_TITLE = "The Unemployed Salt Advisor"
	SITE_DESCRIPTION = "The Salt Will Flow Eventually"
end

set :session_secret, CONFIG['session_secret']
enable :sessions


set :port, CONFIG['port']
set :bind, CONFIG['bind']
set :run, true

use Rack::Flash, :sweep => true

get '/' do
	content_type 'text/html'
	erb :home
end

get "/update" do
	redirect to('/') unless request.xhr?
	content_type :json
	if ($active_match)
		red = $active_red
		blue = $active_blue
		halt 200, {
			:active => true,
			:red_name => red.name,
			:red_rating => red.rating,
			:red_expected => $rating_red.expected,
			:red_provisional => red.provisional?,
			:red_wins => Match.where(:victor => red).count,
			:red_matches => red.matches.count,
			:blue_name => blue.name,
			:blue_rating => blue.rating,
			:blue_expected => $rating_blue.expected,
			:blue_provisional => blue.provisional?,
			:blue_wins => Match.where(:victor => blue).count,
			:blue_matches => blue.matches.count
		}.to_json
	else
		halt 200, {
			:active => false
		}.to_json
	end
end

not_found do
	halt 404, 'not found'
end
