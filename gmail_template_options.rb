  def approval(body, files)
    decision = ask("#{body}\n\n Okay to send to Gmail as a draft? Y/N")
    if decision.upcase == 'Y'
      get_credentials_and_send_email(body, files)
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
