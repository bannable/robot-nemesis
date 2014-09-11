def close_guess(left,right,draw = false)
	if (draw)
		diff = (left - right).abs
		return diff <= GUESS_RANGE
	else
		return left > right
	end
end
