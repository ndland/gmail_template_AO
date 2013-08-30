require 'highline/import'
require './lib/draft_saver'
require './lib/deadline'

class ChallengeCli
  attr_accessor :draft

  def initialize
    @draft = Draft_saver.new
  end

  def set_draft_attributes(timeframe)
    @email = ask("What is the email address you'd like to send it to?")
    @date = ask("What date would you like to send this email on? YYYY-MM-DD 12:00am\n")
    name = ask("What is the name of the candidate?")
    deadline = Deadline.new(@date, timeframe)
    return { "name" => name, "deadline" => deadline.value }
  end

  def approval(body, files)
    decision = ask("#{body}\n\n Okay to send to Gmail as a draft? Y/N")
    if decision.upcase == 'Y'
      get_credentials_and_save_draft(body, files)
    end
  end

  def get_credentials_and_save_draft(body, files)
    credentials = get_credentials
    @draft.save_draft(body, files, @email, credentials)
    if @draft.successful
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
end
