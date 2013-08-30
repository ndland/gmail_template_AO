require 'active_support/core_ext/integer/inflections'

class Deadline
	attr_accessor :value
  def initialize(date, timeframe)
    deadline = Time.parse(date) + (timeframe * 3600)
    @value = deadline.strftime("%-I:%M%P " + deadline.zone + " %A #{time_of_day(deadline)}, %B #{deadline.day.ordinalize}")
  end

	# formatting
private
  def time_of_day(time)
    case time.hour
    when 0...12
      return 'Morning'
    when 12...18
      return 'Afternoon'
    when 18...24
      return 'Evening'
    end
  end
end
