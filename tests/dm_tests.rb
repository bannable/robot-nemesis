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

assert_nil Fighter.get(1)

alpha = Fighter.create( :name => 'Alpha' )
beta = Fighter.create( :name => 'Beta' )

assert_not_nil alpha
assert_not_nil beta
assert_not_equal alpha, beta

test = Fighter.first(:name => 'Alpha')

assert_equal test, alpha

test = Fighter::find_or_create('Charlie')
assert_equal test.name, 'Charlie'
test = Fighter::find_or_create('Alpha')
assert_equal test.name, 'Alpha'
assert_not_nil test.created_at

alpha = Fighter::find_or_create('Charlie')
beta = Fighter::find_or_create('Beta')
match = Match.create(:victor => alpha)

assert_not_nil match

afm = FighterMatch.create(:fighter => alpha, :match => match, :color => 'red')
bfm = FighterMatch.create(:fighter => beta, :match => match, :color => 'blue')

assert_not_nil afm
assert_not_nil bfm
assert_equal bfm.fighter.name, 'Beta'
assert_equal afm.fighter.name, 'Charlie'
assert_equal beta.matches.first.victor.name, 'Charlie'

assert_match PATTERN_NEW, "Bets are OPEN for Ultimat goku vs Shazam! (B Tier)  (matchmaking) www.saltybet.com"
assert_match PATTERN_NEW_SPLIT, "Bets are OPEN for Ultimat goku vs Shazam! (B Tier)  (matchmaking) www.saltybet.com"
assert_not_match PATTERN_NEW_SPLIT, "Bets are locked. Pentagon & black hole (4) - $470,195, Lio convoy (-6) - $312,784"
#
#TODO: Pattern testing for remaining patterns
#
assert_match PATTERN_MM_START, "Bets are locked. Pentagon & black hole (4) - $470,195, Lio convoy (-6) - $312,784"
assert_not_match PATTERN_MM_START, "Bets are locked. Bospider- $480,332, King_leo- $63,710"
assert_match PATTERN_MM_END, "Pentagon & black hole wins! Payouts to Team Red. 84 more matches until the next tournament!"

assert_match PATTERN_EX_START, "Bets are locked. Bospider- $480,332, King_leo- $63,710"
assert_match PATTERN_EX_END, "Team WhyTheFuckNot wins! Payouts to Team Blue. 21 exhibition matches left!"

assert_match PATTERN_TO_END, "Orochi vega wins! Payouts to Team Red. 12 characters are left in the bracket!"


puts "All tests have passed."
sleep 3
exit

