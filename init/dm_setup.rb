#TODO: For now, we're going to log everything
DataMapper::Logger.new($stdout, :debug)

if (DEVELOPMENT)
	DataMapper.setup(:default, 'sqlite:development.db')
else
	DataMapper.setup(:default, CONFIG['db_driver'])
end

# Fighter (ID) <- FighterMatch(Fighter ID, Match ID, Color) <- Match(ID, Victor, timestamp)
class FighterMatch
	include DataMapper::Resource

	property :color,	String	
	
	belongs_to :fighter,	'Fighter',	:key => true
	belongs_to :match,	'Match',	:key => true

	validates_within :color, :set => [ 'red', 'blue' ]
end

class Fighter
	include DataMapper::Resource

	property :id,		Serial
	property :name,		String,		:required => true, :unique => true
	property :created_at,	DateTime,	:writer => :private
	property :updated_at,	DateTime,	:writer => :private

	has n, :results, 'FighterMatch'
	has n, :matches, :through => :results
	has n, :victories, 'Match', :parent_key => [ :id ], :child_key => [ :victor_id ]

	def self.find_or_create(fname)
		test = Fighter.first(:name => fname)
		if (nil == test)
			new_fighter = Fighter.create(:name => fname)
			return new_fighter
		else
			return test
		end
	end
			

end

class Match
	include DataMapper::Resource

	property :id,		Serial,		:writer => :private
	property :created_at,	DateTime,	:writer => :private
	property :mode,		Integer
	
	has n, :results, 'FighterMatch'
	has n, :fighters, :through => :results
	belongs_to :victor, 'Fighter', :parent_key => [ :id ], :child_key => [ :victor_id ]

	def self.setup(red_fighter, blue_fighter, mode)
		red = Fighter::find_or_create(red_fighter)
		blue = Fighter::find_or_create(blue_fighter)
		match = Match.create(:mode => mode)
		FighterMatch.create(:fighter => blue, :match => match, :color => 'blue')
		FighterMatch.create(:fighter => red, :match => match, :color => 'red')
		return match
	end
end

DataMapper.finalize.auto_upgrade!
