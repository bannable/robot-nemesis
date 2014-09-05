PATTERN_NEW		= /^Bets are OPEN/
PATTERN_NEW_SPLIT	= /^Bets are OPEN for (.*?) vs (.*?)! \(([XSABP]|NEW) Tier\)(?: \(Requested by \w+\))?\s+(?:\(|)(tournament|matchmaking|exhibitions)/
PATTERN_START		= /^Bets are locked/
PATTERN_START_SPLIT	= /^Bets are locked\. (.*?)(?: \([\d-]+\) |)- \$((?:[\d,]+)), (.*?)(?: \([\d-]+\) |)- \$((?:[\d,]+))/
PATTERN_END		= /^((?:.*)) wins! (?:.*) Team (Red|Blue)\. ((?:[\d]+)) (more|characters|exhibition)/
