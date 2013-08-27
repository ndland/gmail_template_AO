require 'net/imap'
require 'time'
require 'highline/import'
require 'mail'
require 'active_support/core_ext/integer/inflections'

class GmailTemplate
  attr_accessor :imap

  def set_draft_attributes(timeframe)
    @email = ask("What is the email address you'd like to send it to?")
    @date = ask("What date would you like to send this email on? YYYY-MM-DD 12:00am\n")
    name = ask("What is the name of the candidate?")
    @deadline = set_deadline(@date, timeframe)
    return { "name" => name, "deadline" => @deadline }
  end

  def set_deadline(date, timeframe)
    deadline = Time.parse(date) + (timeframe * 3600)
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

  def approval(body, files)
    decision = ask("#{body}\n\n Okay to send to Gmail as a draft? Y/N")
    if decision.upcase == 'Y'
      get_credentials_and_save_draft(body, files)
    end
  end

  def get_credentials_and_save_draft(body, files)
    credentials = get_credentials
    successful = save_draft(body, files, credentials)
    if successful
      puts "Draft successfully created. Please schedule to be sent at #{@date} " + "#{Time.parse(@date).zone}"
      return true
    else
      get_credentials_and_save_draft(body, files)
    end
  end

  def get_credentials
    user_name = ask("What is your google username?")
    password = ask("What is your google password?\n") { |input| input.echo = "*" }
    return {"user_name" => user_name, "password" => password}
  end

  def format_draft(body, files, email)
    body.gsub!(/\n/,'<br>')
    mail = Mail.new do
      to email
      html_part do
        content_type 'text/html; charset=UTF-8'
        body body
      end
    end
    files.each do |file|
      mail.add_file(file)
    end
    return mail.to_s
  end

  def save_draft(body, files, credentials)
    mail = format_draft(body, files, @email)
    @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
    @imap.login(credentials["user_name"], credentials["password"])
    @imap.append("[Gmail]/Drafts", mail, [:Draft], Time.now)
    return true
  rescue Net::IMAP::NoResponseError
    return false
  end
end
