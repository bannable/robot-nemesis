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
		elsif (blue.name == winner)
			match.victor = blue
			blue_rating.win
			red_rating.lose
		else
			blue_rating.draw
			red_rating.draw
		end
		match.save

		puts "RATINGS UPDATED"
		puts "Blue: #{blue.rating} --> #{blue_rating.new_rating}"
		puts "Red: #{red.rating} --> #{red_rating.new_rating}"
		blue.update_rating(blue_rating.new_rating)
		red.update_rating(red_rating.new_rating)
	end

	def self.setup(red_fighter, blue_fighter, mode)
		red = Fighter::first_or_create(red_fighter)
		blue = Fighter::first_or_create(blue_fighter)
		match = Match.create(:mode => mode)
		FighterMatch.create(:fighter => blue, :match => match, :color => 'blue')
		FighterMatch.create(:fighter => red, :match => match, :color => 'red')
		return match
	end
end


