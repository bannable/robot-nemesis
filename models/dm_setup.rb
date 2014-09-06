if (DEVELOPMENT)
	DataMapper::Logger.new($stdout, :debug)
	if (CONFIG['dev_db'])
		DataMapper.setup(:default, 'sqlite:development.db')
	else
		DataMapper.setup(:default, CONFIG['db_driver'])
	end
else
	DataMapper.setup(:default, CONFIG['db_driver'])
end
