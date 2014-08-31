
# Expected output is:
# 	Test is empty
# 	Alpha
# 	Beta
# 	Alpha
# 	Charlie
# 	Alpha <epoch>
# 	"AFM: Charlie red"
# 	"BFM: Alpha blue"
# 	"Charlie"

test = Fighter.get(1)
if (nil == test)
	puts "Test is empty"
else
	puts test.name
end

alpha = Fighter.create(
	:name => 'Alpha'
)

beta = Fighter.create(
	:name => 'Beta'
)

test = Fighter.first(:name => 'Alpha')

puts alpha.name
puts beta.name
if (nil == test)
	puts "Test is empty"
else
	puts test.name
end
test = Fighter::find_or_create('Charlie')
puts test.name
test = Fighter::find_or_create('Alpha')
puts test.name << test.created_at.strftime(' %s')

alpha = Fighter::find_or_create('Charlie')
beta = Fighter::find_or_create('Beta')
match = Match.create(:victor => alpha)
afm = FighterMatch.create(:fighter => alpha, :match => match, :color => 'red')
bfm = FighterMatch.create(:fighter => beta, :match => match, :color => 'blue')
p "AFM: " << afm.fighter.name << " #{afm.color}"
p "BFM: " << bfm.fighter.name << " #{bfm.color}"
p alpha.matches.first.victor.name

exit

