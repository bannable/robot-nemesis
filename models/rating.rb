class Rating
	# Based on iain's elo gem
	
	def initialize(attributes = {})
		attributes.each do |key, value|
			instance_variable_set("@#{key}", value)
		end
	end

	# Elo rating of the opponent. Not adjusted.
	attr_reader :opp_rating
	# Elo rating of the Fighter we want to update.
	attr_reader :old_rating
	# k-factor for our Fighter
	attr_reader :k_factor
	# Result from the perspective of ourselves
	attr_reader :result

	def result
		raise "Invalid result: #{@result.inspect}" unless valid_result?
		@result.to_f
	end

	def valid_result?
		(0..1).include? @result
	end

	def win
		@result = 1.0
	end

	def draw
		@result = 0.5
	end

	def lose
		@result = 0.0
	end

	def expected
		1.0 / ( 1.0 + ( 10.0 ** ((opp_rating.to_f - old_rating.to_f) / 400.0) ) )
	end

	def change
		k_factor.to_f * ( result.to_f - expected )
	end

	def new_rating
		(old_rating.to_f + change).to_i
	end

end
