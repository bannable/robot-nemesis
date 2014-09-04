require 'cinch'
require 'data_mapper'
require 'json'
require 'yaml'
require './init/constants'

CONFIG = YAML.load_file('config/config.yml') unless defined? CONFIG
DEVELOPMENT = CONFIG['dev']
require './init/dm_setup'

if (DEVELOPMENT)
	require './tests/dm_tests'
end

$game_mode = 'unknown'

def update_mode(input)
	case input
	when 'matchmaking'
		$game_mode = 'mm'
	when 'characters'
		$game_mode = 'to'
	when 'exhibition'
		$game_mode = 'ex'
	else
		$game_mode = 'unknown'
	end
	if (DEVELOPMENT)
	       	puts "Game mode updated to: " << $game_mode.upcase
	end
end


# Create our first bot -- this one is our twitch interface
scraper = Cinch::Bot.new do
	bot_ready = false
	configure do |c|
		c.nick = CONFIG['bot_name']
		c.user = CONFIG['bot_name']
		c.realname = CONFIG['bot_name']
		c.server = "irc.twitch.tv"
		c.channels = ["#saltybet"]
		c.password = 'oauth:' << CONFIG['oauth_token']
	end

	on :connect do
		sleep 10
		bot_ready = true
		puts 'Bot is now ready for action.'
	end

	on :message, PATTERN_NEW do |m|
		if (m.user == "waifu4u" && PATTERN_NEW_SPLIT =~ m.message)
			if (DEVELOPMENT) 
				puts "Game mode is currently: " << $game_mode.upcase
			end
			update_mode($4)
			if ($game_mode == 'ex')
				# Do not create entries from Exhibition fights
				puts "Red: " << $1
				puts "Blue: " << $2
			elsif ($game_mode == 'unknown')
				puts "How did we get here?"
			       	puts m
				exit
			else
				red = Fighter::first_or_create(:name => $1)
				blue = Fighter::first_or_create(:name => $2)
				puts "Red: " << red.name
				puts "Blue: " << blue.name
			end
			puts "Mode: " << $game_mode.upcase << " (Tier: #{$3})"
		end
	end

	on :message, PATTERN_START do |m|
		if (m.user == "waifu4u" && PATTERN_START_SPLIT =~ m.message)
			if (DEVELOPMENT)
			       	puts "Game mode is currently: " << $game_mode.upcase
			end
			if ($game_mode == 'ex')
				# Do not create entries from Exhibition fights
				puts "Red: " << $1 << " (#{$2})"
				puts "Blue: " << $3 << " (#{$4})"
			elsif ($game_mode != 'unknown')
				red = Fighter::first_or_create(:name => $1)
				blue = Fighter::first_or_create(:name => $3)
				puts "Red: " << red.name << "[#{$1}] (#{$2})"
				puts "Blue: " << blue.name << "[#{$3}] (#{$4})"
				puts "Current mode is: " << $game_mode.upcase
			end
		end
	end	

	on :message, PATTERN_END do |m|
		if (m.user == "waifu4u" && PATTERN_END =~ m.message)
			puts "Winner #{$1} (#{$2})"
			puts "Current mode " << $game_mode.upcase << " changes in #{$3} matches"
		end
	end

	trap "SIGINT" do
		puts "Total Fighters created: "
		puts Fighter.count
		scraper.quit
	end
end

scraper.start
