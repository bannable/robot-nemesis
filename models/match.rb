class Match
	include DataMapper::Resource

	property :id,		Serial,		:writer => :private
	property :created_at,	DateTime,	:writer => :private
	property :mode,		String,		:length => 15
	
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
			:bets => blue_bet)
		FighterMatch.create(
			:fighter => red,
			:match => match,
			:color => 'red',
			:rating => red_rating.old_rating,
			:bets => red_bet)
		if (red.name == winner)
			match.victor = red
			blue_rating.lose
			red_rating.win
			loser = blue
			win_rat = red_rating
			lose_rat = blue_rating
		elsif (blue.name == winner)
			match.victor = blue
			blue_rating.win
			red_rating.lose
			loser = red
			win_rat = blue_rating
			lose_rat = red_rating
		else
			loser = nil
			blue_rating.draw
			red_rating.draw
		end
		match.save

		match.victor.update_rating(win_rat.new_rating)
		if (!match.victor.provisional?)
			loser.update_rating(lose_rat.new_rating)
		end
	end
end


