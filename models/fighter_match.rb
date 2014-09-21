class FighterMatch < Sequel::Model
	set_primary_key :id

	many_to_one :fighter
	many_to_one :match

	def validate
		super
		validates_type String, :color
		validates_max_length 10, :color
		validates_integer :bets, :allow_nil=>true
		validates_integer :rating, :allow_nil=>true
	end
end
