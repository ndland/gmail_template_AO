require 'net/imap'

class GmailTemplate

  # attr_accessor :imap

  def user_io(output)
    puts output
    gets.chomp
  end

  def set_draft_attributes
    user_io("What is the email address you'd like to send it to?")
    user_io("What is the name of the candidate?")
    user_io("What date would you like to send this email on?")
  end



  # def logging_in(email, password)
  #   @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
  #   @imap.login(email, password)
  #   return true
  # rescue Net::IMAP::NoResponseError
  #   return false
  # end
end
