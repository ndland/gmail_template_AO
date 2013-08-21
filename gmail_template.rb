require 'net/imap'
require 'time'

class Fixnum
  def ordinalize
    if (11..13).include?(self % 100)
      "#{self}th"
    else
      case self % 10
      when 1; "#{self}st"
      when 2; "#{self}nd"
      when 3; "#{self}rd"
      else    "#{self}th"
      end
    end
  end
end

class GmailTemplate

  def start
    construct_draft()
  end

  def user_io(output)
    puts output
    gets.chomp
  end

  def set_draft_attributes
    @email = user_io("What is the email address you'd like to send it to?")
    @date = user_io("What date would you like to send this email on?")
    @name = user_io("What is the name of the candidate?")
    set_deadline(@date)
  end

  def set_deadline(date)
    hours, minutes, seconds = 63, 60, 60
    deadline = Time.parse(date) + (hours * minutes * seconds)
    deadline.strftime("%-I%P " + deadline.zone + " %A Morning, %B #{deadline.day.ordinalize}")
  end

  def construct_draft
    set_draft_attributes()
  end


  # def logging_in(email, password)
  #   @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
  #   @imap.login(email, password)
  #   return true
  # rescue Net::IMAP::NoResponseError
  #   return false
  # end
end

# application = GmailTemplate.new
# application.start
