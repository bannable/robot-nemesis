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
		match = Match.new(:mode => mode)
		FighterMatch.create(
			:fighter => blue,
			:match => match,
			:color => 'blue',
			:rating => red_rating.old_rating,
			:bets => blue_bet
		)
		FighterMatch.create(
			:fighter => red,
			:match => match,
			:color => 'red',
			:rating => red_rating.old_rating,
			:bets => red_bet
		)
		if (red.name == winner)
			match.correct = red_rating.expected > blue_rating.expected ? true : false
			match.victor = red
			blue_rating.lose
			red_rating.win
		elsif (blue.name == winner)
			match.correct = red_rating.expected > blue_rating.expected ? false: true
			match.victor = blue
			blue_rating.win
			red_rating.lose
		else
			blue_rating.draw
			red_rating.draw
		end
		match.save

		if (red.provisional? && !blue.provisional?)
			red.update_rating(red_rating.new_rating)
		elsif (!red.provisional? && blue.provisional?)
			blue.update_rating(blue_rating.new_rating)
		else
			red.update_rating(red_rating.new_rating)
			blue.update_rating(blue_rating.new_rating)
		end
	end
end


