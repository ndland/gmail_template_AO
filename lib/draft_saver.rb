require 'net/imap'
require 'time'
require 'mail'
class Draft_saver
  attr_accessor :imap, :successful

  def save_draft(body, subject, files, email, credentials)
    mail = format_draft(body, subject, files, email)
    @imap = Net::IMAP.new('imap.gmail.com', 993, true, nil, false)
    @imap.login(credentials["user_name"], credentials["password"])
    @imap.append("[Gmail]/Drafts", mail, [:Draft], Time.now)
    @successful = true
  rescue Net::IMAP::NoResponseError
    @successful = false
  end

  private
  def format_draft(body, subject, files, email)
    body.gsub!(/\n/,'<br>')
    mail = Mail.new do
      to email
      subject subject
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
end
