class Fighter < Sequel::Model
	set_primary_key :id

	one_to_many :results, :class=>:FighterMatch
	one_to_many :victories, :key=>:victor, :class=>:Match

	many_to_many :matches, :join_table=>:fighter_matches, :left_key=>:fighter_id, :right_key=>:match_id


	def provisional?
		if (self.match_count < 10)
			return true
		else
			return false
		end
	end

	def k_factor
		mc = self.match_count
		if (mc < 10)
			return 100
		elsif (mc < 15)
			return 50
		elsif (mc < 20)
			return 30
		elsif (mc < 25)
			return 20
		elsif (mc < 30)
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



	def validate
		super
		validates_presence :name
		validates_unique :name
		validates_type String, :name
		validates_integer :rating, :allow_nil=>true
		validates_integer :match_count, :allow_nil=>true
	end

	def before_create
		self.created_at = Time.now
		super
	end

	def before_save
		self.updated_at = Time.now
		super
	end
		
end
