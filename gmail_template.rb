require 'net/imap'
require 'time'
require 'highline/import'
require 'mail'

class GmailTemplate
  attr_accessor :body, :imap

  def start
    decision = 'n'
    until decision.upcase == 'Y'
    construct_draft()
    decision = ask("#{@body}\n\n Okay to send to Gmail as a draft? Y/N")
    end
   save_draft()
  end

  def set_draft_attributes
    @email = ask("What is the email address you'd like to send it to?")
    @date = ask("What date would you like to send this email on?")
    @name = ask("What is the name of the candidate?")
    @deadline = set_deadline(@date)
  end

  def set_deadline(date)
    hours, minutes, seconds = 63, 60, 60
    deadline = Time.parse(date) + (hours * minutes * seconds)
    deadline.strftime("%-I:%M%P " + deadline.zone + " %A Morning, %B #{deadline.day.ordinalize}")
  end

  def construct_draft
    set_draft_attributes()
    @body = "hi #{@name}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by #{@deadline}
blah blah blah

Thanks!"
  end

  def save_draft
    new_body = @body.gsub(/\n/,'<br>')
    email = @email
    logging_in()
    mail = Mail.new do
      to email
      html_part do
        content_type 'text/html; charset=UTF-8'
        body new_body
      end
    end
    @imap.append("[Gmail]/Drafts", mail.to_s, [:Draft], Time.now)

  puts "Draft successfully created. Please schedule to be sent at #{@date} " + "#{Time.parse(@date).zone}"
  end

  def logging_in()
    email = ask("What is your google username?")
    password = ask("What is your google password?\n") { |input| input.echo = "*" }
    @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
    @imap.login(email, password)
  rescue Net::IMAP::NoResponseError
    logging_in()
  end
end

# TODO find tests for this function
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

# application = GmailTemplate.new
# application.start
