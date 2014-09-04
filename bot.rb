require 'cinch'
require 'data_mapper'
require 'json'
require 'yaml'
require './init/dm_setup'
require './init/constants'
require './init/salt'

if (DEVELOPMENT)
	require './tests/dm_tests'
end

CONFIG = YAML.load_file('config.yml') unless defined? CONFIG

# Create our first bot -- this one is our twitch interface
scraper = Cinch::Bot.new do
	bot_ready = false
	configure do |c|
		c.nick = CONFIG['bot_name']
		c.user = CONFIG['bot_name']
		c.realname = CONFIG['bot_name']
		c.server = "irc.twitch.tv"
		c.channels = ["#saltybet"]
		c.password = CONFIG['oauth_token']
	end

	on :connect do
		sleep 10
		bot_ready = true
		puts 'Bot is now ready for action.'
	end


	on :message, PATTERN_NEW do |m|
		return unless m.user == "waifu4u" && bot_ready
		if (PATTERN_NEW_SPLIT =~ m.message)
			puts "Red: #{$1}"
			puts "Blue: #{$2}"
			puts "Tier: #{$3}"
			puts "Mode: #{$4}"
		end
	end

	on :message, PATTERN_START do |m|
		return unless m.user == "waifu4u" && bot_ready
		if (PATTERN_START_SPLIT =~ m.message)
			puts "Red: #{$1} (#{$2})"
			puts "Blue: #{$3} (#{$4})"
		end
	end	

	on :message, PATTERN_END do |m|
		return unless m.user == "waifu4u" && bot_ready
		if (PATTERN_END =~ m.message)
			puts "Winner #{$1} (#{$2})"
			puts "Current mode #{$4} changes in #{$3} matches"
		end
	end

	trap "SIGINT" do
		scraper.quit
	end
end

scraper.start
