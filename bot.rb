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

$active_mode	= 'unknown'
$active_red	= nil
$active_blue	= nil
$active_match	= nil
$active_rfm	= nil
$active_bfm	= nil
$active_locked	= false

def update_mode(input)
	case input
	when 'matchmaking'
		$active_mode = 'mm'
	when 'characters'
		$active_mode = 'to'
	when 'exhibition'
		$active_mode = 'ex'
	else
		$active_mode = 'unknown'
	end
	if (DEVELOPMENT)
	       	debug "Game mode updated to: " << $active_mode
	end
end

def update_active(red, blue, match, rfm, bfm)
	$active_red = red
	$active_blue = blue
	$active_match = match
	$active_rfm = rfm
	$active_bfm = bfm
end

def match_cleanup(messy = false)
	if messy
		if ($active_rfm); $active_rfm.destroy; end
		if ($active_bfm); $active_bfm.destroy; end
		if ($active_red); $active_red.destroy; end
		if ($active_blue); $active_blue.destroy; end
		if ($active_match); $active_match.destroy; end
	end

	$active_red = nil
	$active_blue = nil
	$active_match = nil
	$active_rfm = nil
	$active_bfm = nil
end

def start_bets(left, right)
	debug "Preparing a match between (" << left << ") and (" << right << ")"
	red = Fighter::first_or_create(:name => left)
	blue = Fighter::first_or_create(:name => right)
	match = Match.new
	match.mode = $active_mode
	rfm = FighterMatch.new
	rfm.attributes = { :fighter => red, :match => match, :color => 'red' }
	bfm = FighterMatch.new
	bfm.attributes = { :fighter => blue, :match => match, :color => 'blue' }

	update_active(red, blue, match, rfm, bfm)
end

def start_match(red, red_bet, blue, blue_bet)
	if (red != nil && blue != nil  && (red == $active_red && blue == $active_blue))
		$active_rfm.bets = red_bet.delete(",").to_i
		$active_bfm.bets = blue_bet.delete(",").to_i
		info "Bets for active match set. Let's get ready to rumble."
	else
		warn "Match began that we did not know about: #{red.name} (#{red_bet}) vs #{blue.name} (#{blue_bet})"
		match_cleanup(true)
		return
	end
end

def match_end(victor)
	if ($active_red != victor && $active_blue != victor)
		match_cleanup(true)
		return
	else
		if ($active_mode == 'mm' || $active_mode == 'to')
			$active_match.victor = victor
			$active_match.save
		end
		match_cleanup
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
		info 'Bot is now ready for action.'
	end

	on :message, PATTERN_NEW do |m|
		if (m.user == "waifu4u" && PATTERN_NEW_SPLIT =~ m.message)
			if (DEVELOPMENT) 
				debug "Game mode is currently: " << $active_mode.upcase
			end
			update_mode($4)
			if ($active_mode == 'ex')
				# Do not create entries from Exhibition fights
				debug "Red: " << $1
				debug "Blue: " << $2
			elsif ($active_mode == 'unknown')
				error "How did we get here?"
			       	puts m
				exit
			else
				if ($active_match)
					match_cleanup(true)
				end
				start_bets($1, $2)
			end
			debug "Mode: " << $active_mode.upcase << " (Tier: #{$3})"
		end
	end

	on :message, PATTERN_START do |m|
		if (m.user == "waifu4u" && PATTERN_START_SPLIT =~ m.message)
			if (DEVELOPMENT)
			       	debug "Game mode is currently: " << $active_mode.upcase
			end
			if ($active_mode == 'ex')
				# Do not create entries from Exhibition fights
				debug "Exhibition match; recording no data."
				debug "Red: " << $1 << " (#{$2})"
				debug "Blue: " << $3 << " (#{$4})"
			elsif ($active_mode != 'unknown')
				debug "Not exhibition match..."
				red = Fighter::first_or_create(:name => $1)
				blue = Fighter::first_or_create(:name => $3)
				start_match(red, $2, blue, $4)
			end
		end
	end	

	on :message, PATTERN_END do |m|
		if (m.user == "waifu4u" && PATTERN_END =~ m.message)
			debug "Winner #{$1} (#{$2})"
			if ($4 == 'more')
				learn = 'matchmaking'
			elsif ($4 == 'characters')
				learn = 'tournament'
			elsif ($4 == 'exhibition')
				learn = 'exhibition'
			end
			update_mode(learn)
			debug "Current mode " << $active_mode.upcase << " changes in #{$3} matches"
			match_end($1)
		end
	end

	trap "SIGINT" do
		puts "Total Fighters created: "
		puts Fighter.count
		scraper.quit
	end
end

scraper.start
