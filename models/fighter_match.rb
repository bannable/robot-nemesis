class FighterMatch
	include DataMapper::Resource

	property :color,	String,		:length => 10
	property :bets,		Integer
	property :rating,	Integer
	
	belongs_to :fighter,	'Fighter',	:key => true
	belongs_to :match,	'Match',	:key => true

	validates_within :color, :set => [ 'red', 'blue' ]
end

