class Fighter
	include DataMapper::Resource

	property :id,		Serial
	property :name,		String,		:required => true, :unique => true
	property :created_at,	DateTime,	:writer => :private
	property :updated_at,	DateTime,	:writer => :private
	property :elo,		Integer
	property :tier,		String,		:length => 3
	property :comment,	Text
	property :match_count,	Integer

	has n, :results, 'FighterMatch'
	has n, :matches, :through => :results
	has n, :victories, 'Match', :parent_key => [ :id ], :child_key => [ :victor_id ]
end
