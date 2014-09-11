require 'yaml'
require 'json'

CONFIG = YAML.load_file('config/config.yml') unless defined? CONFIG
DEVELOPMENT = CONFIG['dev']

require 'data_mapper'
require './models/dm_setup'
require './models/rating'
require './models/fighter'
require './models/match'
require './models/fighter_match'
require './helpers/stats'

# Fighter (ID) <- FighterMatch(Fighter ID, Match ID, Color) <- Match(ID, Victor, timestamp)
DataMapper.finalize.auto_upgrade!

PATTERN_NEW		= /^Bets are OPEN/
PATTERN_NEW_SPLIT	= /^Bets are OPEN for (.*?) vs (.*?)! \(([XSABP]|NEW) Tier\)(?: \(Requested by \w+\))?\s+(?:\(|)(tournament|matchmaking|exhibitions)/
PATTERN_START		= /^Bets are locked/
PATTERN_START_SPLIT	= /^Bets are locked\. (.*?)(?: \([\d-]+\) |)- \$((?:[\d,]+)), (.*?)(?: \([\d-]+\) |)- \$((?:[\d,]+))/
PATTERN_END		= /^((?:.*)) wins! (?:.*) Team (Red|Blue)\. ((?:[\d]+)) (more|characters|exhibition)/
GUESS_RANGE		= 0.10
