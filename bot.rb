require 'cinch'

bot = Cinch::Bot.new do
	configure do |c|
		c.server = "irc.quakenet.org"
		c.channels = ["#bm-dev"]
		c.nick = "BanWithRuby"
	end
end

bot.start
