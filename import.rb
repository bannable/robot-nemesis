require './models/setup'

def parse(line)
	if /^(?<mred>.*?) - \$(?<red_bet>[\d]+), (?<mblue>.*?) - \$(?<blue_bet>[\d]++)\s+(?<winner>.*?)\s+\d{1,2}:/ =~ line
		blue = Fighter::first_or_create(:name => mblue)
		red = Fighter::first_or_create(:name => mred)
		r_blue = Rating.new(
			:old_rating => blue.rating,
			:opp_rating => red.rating,
			:k_factor => blue.k_factor
		)
		r_red = Rating.new(
			:old_rating => red.rating,
			:opp_rating => blue.rating,
			:k_factor => red.k_factor
		)
		if (winner != red.name && winner != blue.name)
			winner = nil
		end
		Match::play(red, blue, red_bet, blue_bet, r_red, r_blue, nil, winner)
	end
end

it = 0
start = Time.now
File.open('./tools/data') do |f|
	f.each_line do |line|
		parse line
		it += 1
		if (it % 100 == 0)
			puts "#{it} matches imported..."
		end
	end
end
fin = Time.now

puts "Finished in #{start - fin} seconds."
puts "#{Fighter.count} fighters in #{Match.count} (#{FighterMatch.count}) matches imported."
