#TODO: This is not working. I need a better solution.
class Salt

	STATE_STARTUP		= 0
	STATE_MATCHMAKING	= 1
	STATE_EXHIBITION	= 2
	STATE_TOURNAMENT	= 3

	@current_state = STATE_STARTUP
	@current_match = nil

	def known_state?
		return @@current_state != STATE_STARTUP
	end

	def exhib?
		return @@current_state == STATE_EXHIBITION
	end

	def get_state
		return @current_state
	end

	def set_state(state)
		return false unless (state > 0 && state < 4)
		@current_state = state
		return true
	end

	def get_match
		return @current_match
	end

	def set_match(match)
		return false unless match != nil
		@current_match = match
		return true
	end
end
