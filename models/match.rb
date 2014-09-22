class Match < Sequel::Model
	set_primary_key :id

	one_to_many :results, :class=>:FighterMatch
	many_to_one :victor, :class=>:Fighter
	many_to_many :fighters, :join_table=>:fighter_matches

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
			match.correct = close_guess(red_rating.expected, blue_rating.expected,true)
			blue_rating.draw
			red_rating.draw
		end

		match.save
		match.add_fighter red
		match.add_fighter blue

		rfm = FighterMatch.where(
			:fighter => red,
			:match => match)
		puts rfm.inspect
		bfm = FighterMatch.where(
			:fighter => blue,
			:match => match)
		puts bfm.inspect

		rfm.update(
			:bets => red_bet,
			:rating => red_rating.old_rating,
			:color => 'red'
		)
		bfm.update(
			:bets => blue_bet,
			:rating => blue_rating.old_rating,
			:color => 'blue'
		)

		if (DEVELOPMENT)
			puts match.inspect
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



	def validate
		super
		validates_unique :id
		validates_type String, :mode
		validates_max_length 15, :mode
	end

	def before_create
		self.created_at = Time.now
		super
	end

end


