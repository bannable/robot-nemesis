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

def get_mode(input)
	case input
	when 'more'
		return 'mm'
	when 'characters'
		return 'to'
	when 'exhibition'
		return 'ex'
	else
		return 'mm'
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
		return unless m.user == "waifu4u" && bot_ready
		if (PATTERN_NEW_SPLIT =~ m.message)
			red = Fighter::first_or_create($1)
			blue = Fighter::first_or_create($2)
			puts "Red: " << red.name
			puts "Blue: " << blue.name
			puts "Tier: #{$3}"
			puts "Mode: " << get_mode($4)
		end
	end

	on :message, PATTERN_START do |m|
		return unless m.user == "waifu4u" && bot_ready
		if (PATTERN_START_SPLIT =~ m.message)
			red = Fighter::first_or_create($1)
			blue = Fighter::first_or_create($3)
			puts "Red: " << red.name << " (#{$2})"
			puts "Blue: " << blue.name << " (#{$4})"
		end
	end	

	on :message, PATTERN_END do |m|
		return unless m.user == "waifu4u" && bot_ready
		if (PATTERN_END =~ m.message)
			puts "Winner #{$1} (#{$2})"
			puts "Current mode " << get_mode($4).upcase << " changes in #{$3} matches"
		end
	end

	trap "SIGINT" do
		puts "Total Fighters created: "
		puts Fighter.count
		scraper.quit
	end
end

scraper.start
