require 'net/imap'
require 'time'
require 'highline/import'

class GmailTemplate
  attr_accessor :body, :imap

  def start
    decision = 'n'
    until decision.upcase == 'Y'
    construct_draft()
    decision = user_io("#{@body}\n\n Okay to send to Gmail as a draft? Y/N")
    end
   save_draft()
  end

  def user_io(output)
    puts output
    gets.chomp
  end

  def set_draft_attributes
    @email = user_io("What is the email address you'd like to send it to?")
    @date = user_io("What date would you like to send this email on?")
    @name = user_io("What is the name of the candidate?")
    @deadline = set_deadline(@date)
  end

  def set_deadline(date)
    hours, minutes, seconds = 63, 60, 60
    deadline = Time.parse(date) + (hours * minutes * seconds)
    deadline.strftime("%-I%P " + deadline.zone + " %A Morning, %B #{deadline.day.ordinalize}")
  end

  def construct_draft
    set_draft_attributes()
    @body = "hi #{@name}!

Complete the problem presented in this...your resulting project to us at <a href ='mailto: detroit.jobs@atomicobject.com'>detroit.jobs@atomicobject.com</a> by #{@deadline}
blah blah blah

Thanks!"
  end

  def save_draft
    logging_in()
    @imap.append("[Gmail]/Drafts", <<EOF, [:Draft], Time.now)
     TO: #{@email}

#{@body}
EOF

  puts "Draft successfully created. Please schedule to be sent at #{@date} " + "#{Time.parse(@date).zone}"
  end

  def logging_in()
    email = user_io("What is your google username?")
    password = ask("What is your google password?\n") { |input| input.echo = "*" }
    @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
    @imap.login(email, password)
  rescue Net::IMAP::NoResponseError
    logging_in()
  end
end

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

#application = GmailTemplate.new
#application.start
