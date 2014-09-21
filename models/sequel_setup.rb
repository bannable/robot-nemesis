if (DEVELOPMENT)
	if (CONFIG['dev_db'])
		DB = Sequel.connect('sqlite://development.db')
	else
		DB = Sequel.sqlite
	end
	DB.loggers << Logger.new($stdout)
else
	DB = Sequel.connect(CONFIG['db_driver'])
end

DB.create_table? :fighters do
	primary_key	:id
	String		:name,		:unique=>true
	DateTime	:created_at
	DateTime	:updated_at
	String		:tier,		:size=>3
	String		:comment,	:text=>true
	Integer		:match_count,	:default=>0
	Integer		:rating,	:default=>1300
end

DB.create_table? :matches do
	primary_key	:id
	DateTime	:created_at
	String		:mode,		:size=>15
	Boolean		:correct,	:default=>false

	foreign_key :victor_id, :fighters
end

DB.create_table? :fighter_matches do
	primary_key	:id
	String		:color,		:size=>10	
	Integer		:bets
	Integer		:rating

	foreign_key :fighter_id, :fighters
	foreign_key :match_id, :matches
end	

Sequel::Model.plugin :validation_helpers
