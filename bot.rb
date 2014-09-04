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

@game_mode = 'unknown'

def update_mode(input)
	case input
	when 'more'
		@game_mode = 'mm'
	when 'characters'
		@game_mode = 'to'
	when 'exhibition'
		@game_mode = 'ex'
	else
		@game_mode = 'unknown'
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
		return unless m.user == "waifu4u"
		if (PATTERN_NEW_SPLIT =~ m.message)
			update_mode($4)
			if @game_mode == 'ex'
				# Do not create entries from Exhibition fights
				puts "Red: " << $1
				puts "Blue: " << $2
			else
				red = Fighter::first_or_create($1)
				blue = Fighter::first_or_create($2)
				puts "Red: " << red.name
				puts "Blue: " << blue.name
			end
			puts "Mode: " << @game_mode.upcase << " (Tier: #{$3})"
		end
	end

	on :message, PATTERN_START do |m|
		return unless m.user == "waifu4u"
		if (PATTERN_START_SPLIT =~ m.message)
			if (@game_mode == nil)
				# Our state is unknown. Do not record match.
				return
			elsif (@game_mode == 'ex')
				# Do not create entries from Exhibition fights
				puts "Red: " << $1 << " (#{$2})"
				puts "Blue: " << $3 << " (#{$4})"
			else
				red = Fighter::first_or_create($1)
				blue = Fighter::first_or_create($3)
				puts "Red: " << red.name << " (#{$2})"
				puts "Blue: " << blue.name << " (#{$4})"
				puts "Current mode is: " << @game_mode.upcase
			end
		end
	end	

	on :message, PATTERN_END do |m|
		return unless m.user == "waifu4u"
		if (PATTERN_END =~ m.message)
			puts "Winner #{$1} (#{$2})"
			puts "Current mode " << @game_mode.upcase << " changes in #{$3} matches"
		end
	end

	trap "SIGINT" do
		puts "Total Fighters created: "
		puts Fighter.count
		scraper.quit
	end
end

scraper.start
