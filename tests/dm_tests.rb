module Test
	FailedAssertionError = Class.new(StandardError)

	def failure(msg)
		raise FailedAssertionError, msg
	end

	def assert(condition, msg=nil)
		msg ||='Test failed.'
		failure(msg) unless condition
	end

	def assert_equal(expected, actual, msg=nil)
		msg ||= "Expected #{expected.inspect} to equal #{actual.inspect}"
		assert(expected == actual, msg)
	end

	def assert_not_equal(expected, actual, msg=nil)
		msg ||= "Expected #{expected.inspect} to not equal #{actual.inspect}"
		assert(expected != actual, msg)
	end

	def assert_nil(actual, msg=nil)
		msg ||= "Expected #{actual.inspect} to be nil"
		assert(nil == actual, msg)
	end

	def assert_not_nil(actual, msg=nil)
		msg ||= "Expected #{actual.inspect} to be not nil"
		assert(nil != actual, msg)
	end

	def assert_match(pattern, actual, msg=nil)
		msg ||= "Expected #{actual.inspect} to match #{pattern.inspect}"
		assert(pattern =~ actual, msg)
	end

	def assert_not_match(pattern, actual, msg=nil)
		msg ||= "Expected #{actual.inspect} to not match #{pattern.inspect}"
		assert(pattern !~ actual, msg)
	end
end

include Test

assert_match PATTERN_NEW, "Bets are OPEN for Ultimat goku vs Shazam! (B Tier)  (matchmaking) www.saltybet.com"

assert_not_nil PATTERN_NEW_SPLIT =~ "Bets are OPEN for Ultimat goku vs Shazam! (B Tier)  (matchmaking) www.saltybet.com"
assert_equal $2, 'Shazam'

assert_not_nil PATTERN_NEW_SPLIT =~ "Bets are OPEN for Opera elmer vs Team reimisen! (B Tier) tournament bracket: http://www.saltybet.com/shaker?bracket=1"
assert_equal $2, 'Team reimisen'

assert_match PATTERN_START, "Bets are locked. Pentagon & black hole (4) - $470,195, Lio convoy (-6) - $312,784"

assert_not_nil PATTERN_START_SPLIT =~ "Bets are locked. Pentagon & black hole (4) - $470,195, Lio convoy (-6) - $312,784"
assert_equal $2, "470,195"


assert_not_nil PATTERN_START_SPLIT =~ "Bets are locked. ALSOAFIGHTER- $480,332, THISGUYASWELL- $63,710"
assert_equal $1, 'ALSOAFIGHTER'

assert_not_nil PATTERN_END =~ "Shaq Diesel wins! Payouts to Team Blue. 20 exhibition matches left!" 
assert_equal $1, 'Shaq Diesel'
assert_equal $2, 'Blue'
assert_equal $3, '20'
assert_equal $4, 'exhibition'

assert_not_nil PATTERN_END =~ "Pentagon & black hole wins! Payouts to Team Red. 84 more matches until the next tournament!"
assert_not_nil PATTERN_END =~ "Orochi vega wins! Payouts to Team Red. 12 characters are left in the bracket!"
assert_nil PATTERN_END =~ "Orochi vega wins! Payouts to Team Red. 1a2 characters are left in the bracket!"

puts "All tests have passed. Continuing execution in 3 seconds..."


