class Match
	include DataMapper::Resource

	property :id,		Serial,		:writer => :private
	property :created_at,	DateTime,	:writer => :private
	property :mode,		String,		:length => 15
	property :correct,	Boolean
	
	has n, :results, 'FighterMatch'
	has n, :fighters, :through => :results
	belongs_to :victor, 'Fighter' 

	def self.play(red, blue, red_bet, blue_bet, red_rating, blue_rating, mode, winner = nil)
		if (DEVELOPMENT)
			puts "RED OLD MATCH COUNT: #{red.matches.count}"
		end
		match = Match.new(:mode => mode)
		if (red.name == winner)
			match.correct = close_guess(red_rating.expected, blue_rating.expected)
			match.victor = red
			blue_rating.lose
			red_rating.win
		elsif (blue.name == winner)
			match.correct = close_guess(blue_rating.expected, red_rating.expected)
			match.victor = blue
			blue_rating.win
			red_rating.lose
		else
			match.correct = close_guess(red_rating.expected, blue_rating.expected)
			blue_rating.draw
			red_rating.draw
		end
		match.save
		
		if (DEVELOPMENT)
			puts "CREATING NEW MATCH: #{match.saved?}"
			puts match.inspect
		end

		bfm = FighterMatch.new
		bfm.attributes = {
			:fighter => blue,
			:match => match,
			:color => 'blue',
			:rating => blue_rating.old_rating,
			:bets => blue_bet
		}
		rfm = FighterMatch.new
		rfm.attributes = { 
			:fighter => red,
			:match => match,
			:color => 'red',
			:rating => red_rating.old_rating,
			:bets => red_bet
		}

		bfm.save
		rfm.save

		if (DEVELOPMENT)
			puts "CREATING NEW RFM: #{rfm.saved?}"
			puts rfm.inspect
			puts "CREATING NEW BFM: #{bfm.saved?}"
			puts bfm.inspect
			puts "RED NEW MATCH COUNT: #{red.matches.count}"
		end

		if (red.provisional? && !blue.provisional?)
			red.update_rating(red_rating.new_rating)
			if (blue.name == winner)
				blue.update_rating(blue_rating.new_rating)
			end
		elsif (!red.provisional? && blue.provisional?)
			blue.update_rating(blue_rating.new_rating)
			if (red.name == winner)
				red.update_rating(red_rating.new_rating)
			end
		else
			red.update_rating(red_rating.new_rating)
			blue.update_rating(blue_rating.new_rating)
		end
	end
end


