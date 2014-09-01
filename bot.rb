require 'cinch'
require 'data_mapper'
require './config/config.rb'
require './init/dm_setup'
require './init/constants'

if (DEVELOPMENT)
	require './tests/dm_tests'
end

# Create our first bot -- this one is our twitch interface
scraper = Cinch::Bot.new do
	configure do |c|
		c.nick = BOT_NAME
		c.user = BOT_NAME
		c.realname = BOT_NAME
		c.server = "irc.twitch.tv"
		c.channels = ["#saltybet"]
		c.password = BOT_OAUTH_TOKEN 
	end

	on :message, PATTERN_NEW do |m|
		return unless m.user == "waifu4u"
		if match = m.message.match(PATTERN_NEW_SPLIT)
		       	#red, blue, tier, mode = match[1], match[2], match[3], match[4]
			red, blue, tier, mode = match
			debug "Red: #{red}"
			debug "Blue: #{blue}"
			debug "Tier: #{tier}"
			debug "Mode: #{mode}"
		end
	end

	trap "SIGINT" do
		scraper.quit
	end
end

scraper.start
