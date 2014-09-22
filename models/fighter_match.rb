class FighterMatch < Sequel::Model
	many_to_one :fighter
	many_to_one :match

	set_primary_key [:fighter, :match]

	def validate
		super
		validates_type String, :color
		validates_max_length 10, :color
		validates_integer :bets, :allow_nil=>true
		validates_integer :rating, :allow_nil=>true
	end
end
