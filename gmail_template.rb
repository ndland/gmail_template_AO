require 'net/imap'
require 'time'
require 'highline/import'
require 'mail'
require 'active_support/core_ext/integer/inflections'

class GmailTemplate
  attr_accessor :body, :imap

  def approval(body, files)
    decision = ask("#{body}\n\n Okay to send to Gmail as a draft? Y/N")
    if decision.upcase == 'Y'
      save_draft(body, files)
      return true
    end
  end

  def set_draft_attributes(timeframe)
    @email = ask("What is the email address you'd like to send it to?")
    @date = ask("What date would you like to send this email on? YYYY-MM-DD 12:00am\n")
    @name = ask("What is the name of the candidate?")
    @deadline = set_deadline(@date, timeframe)
    attributes = { "name" => @name, "deadline" => @deadline }
    return attributes
  end

  def set_deadline(date, timeframe)
    deadline = Time.parse(date) + timeframe
    deadline.strftime("%-I:%M%P " + deadline.zone + " %A #{time_of_day(deadline)}, %B #{deadline.day.ordinalize}")
  end

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

  def save_draft(body, files)
    new_body = body.gsub(/\n/,'<br>')
    email = @email
    logging_in()
    mail = Mail.new do
      to email
      html_part do
        content_type 'text/html; charset=UTF-8'
        body new_body
      end
    end
    files.each do |file|
      mail.add_file(file)
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


# application = GmailTemplate.new
# application.start
