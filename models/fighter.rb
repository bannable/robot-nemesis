class Fighter
	include DataMapper::Resource

	property :id,		Serial
	property :name,		String,		:required => true, :unique => true
	property :created_at,	DateTime,	:writer => :private
	property :updated_at,	DateTime,	:writer => :private
	property :tier,		String,		:length => 3
	property :comment,	Text
	property :match_count,	Integer,	:default => 0, :required => true
	property :rating,	Integer,	:default => 1000, :required => true

	has n, :results, 'FighterMatch'
	has n, :matches, :through => :results
	has n, :victories, 'Match', :parent_key => [ :id ], :child_key => [ :victor_id ]

	def provisional?
		if (@match_count < 7)
			return true
		else
			return false
		end
	end

	def k_factor
		if (@match_count < 10)
			return 100
		elsif (@match_count < 15)
			return 50
		elsif (@match_count < 20)
			return 30
		elsif (@match_count < 25)
			return 20
		elsif (@match_count < 30)
			return 10
		else
			return 7
		end
	end

	def update_rating(new_rating)
		self.rating = new_rating
		self.match_count += 1
		self.save
	end
		
end
