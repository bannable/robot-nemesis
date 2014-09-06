class Match
	include DataMapper::Resource

	property :id,		Serial,		:writer => :private
	property :created_at,	DateTime,	:writer => :private
	property :mode,		String,		:length => 15
	
	has n, :results, 'FighterMatch'
	has n, :fighters, :through => :results
	belongs_to :victor, 'Fighter' 

	def self.setup(red_fighter, blue_fighter, mode)
		red = Fighter::first_or_create(red_fighter)
		blue = Fighter::first_or_create(blue_fighter)
		match = Match.create(:mode => mode)
		FighterMatch.create(:fighter => blue, :match => match, :color => 'blue')
		FighterMatch.create(:fighter => red, :match => match, :color => 'red')
		return match
	end
end

