require './gmail_template'

class DeveloperTemplate

  attr_accessor :template

  def start
    developer_template = 'hi #{@name}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline}
blah blah blah

Thanks!'

    @template = GmailTemplate.new
    @template.start(developer_template)
  end
end
