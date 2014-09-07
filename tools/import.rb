require '../models/setup.rb'

def parse(line)
	/^(?<mred>.*?) - \$(?<red_bet>[\d]+), (?<mblue>.*?) - \$(?<blue_bet>[\d]++)\s+(?<winner>.*?)\s+\d{1,2}:/ =~ line
	puts "#{mred},#{red_bet},#{mblue},#{blue_bet},#{winner}"
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
	Match::play(red, blue, red_bet, blue_bet, r_red, r_blue, nil, winner)
end

it = 0
File.open('./data') do |f|
	f.each_line do |line|
		parse line
		it += 1
		if (it % 10 == 0)
			puts "#{it} matches imported..."
		end
	end
end

puts "Finished."
puts "#{Fighter.count} fighters in #{Match.count} matches imported."
