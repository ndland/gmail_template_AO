require 'net/imap'
require 'time'
require 'mail'
class Draft
  attr_accessor :imap
	# mail
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

	# mail
  def save_draft(body, files, email, credentials)
    mail = format_draft(body, files, email)
    @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
    @imap.login(credentials["user_name"], credentials["password"])
    @imap.append("[Gmail]/Drafts", mail, [:Draft], Time.now)
    return true
  rescue Net::IMAP::NoResponseError
    return false
  end
end
