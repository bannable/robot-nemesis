require './models/setup'
require 'cinch'

$active_mode	= 'unknown'
$active_red	= nil
$active_blue	= nil
$active_match	= false
$active_rfm_bet	= nil
$active_bfm_bet	= nil

def update_mode(input)
	case input
	when 'matchmaking'
		$active_mode = 'mm'
	when 'characters', 'tournament'
		$active_mode = 'to'
	else
		$active_mode = 'ex'
	end
	if (DEVELOPMENT)
	       	warn "Game mode updated to: " << $active_mode
	end
end

def update_active(red, blue, match, rfm_bet, bfm_bet)
	$active_red = red
	$active_blue = blue
	$active_match = match
	$active_rfm_bet = rfm_bet
	$active_bfm_bet = bfm_bet
end

def match_cleanup
	$active_red = nil
	$active_blue = nil
	$active_match = nil
	$active_rfm_bet = nil
	$active_bfm_bet = nil
end

def start_bets(left, right)
	debug "Preparing a match between (" << left << ") and (" << right << ")"
	red = Fighter::first_or_create(:name => left)
	blue = Fighter::first_or_create(:name => right)
	update_active(red, blue, true, nil, nil)
end

def start_match(red, red_bet, blue, blue_bet)
	if (red != nil && blue != nil  && (red == $active_red && blue == $active_blue))
		$active_rfm_bet = red_bet.delete(",").to_i
		$active_bfm_bet = blue_bet.delete(",").to_i
		info "Bets for active match set. Let's get ready to rumble."
	else
		debug "Match began that we did not know about: #{red.name} (#{red_bet}) vs #{blue.name} (#{blue_bet})"
		match_cleanup
		return
	end
end

def match_end(winner)
	if ($active_match)
		if ($active_mode == 'mm' || $active_mode == 'to')
			match = Match.new
			match.mode = $active_mode
			if ($active_red.name == winner)
				match.victor = $active_red
			else
				match.victor = $active_blue
			end
			match.save
			FighterMatch.create( :fighter => $active_red, :match => match, :bets => $active_rfm_bet, :color => 'red' )
			FighterMatch.create( :fighter => $active_blue, :match => match, :bets => $active_bfm_bet, :color => 'blue' )
			fighter = Fighter.first(:name => winner)
			debug "Match is over, testing cleanup..."
			puts match.victor.name
			m = Match.first( :victor => fighter )
			puts m.victor.name
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
		bot_ready = true
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
			else
				match_cleanup
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
			else
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
		puts Fighter.count
		puts Match.count
		match_cleanup
		scraper.quit
	end
end

scraper.start
