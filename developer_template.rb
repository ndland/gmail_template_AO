require './gmail_template'

class DeveloperTemplate

  attr_accessor :template, :developer_template

  def initialize
    @template = GmailTemplate.new
    @approved = false
    @files = []
    @timeFrame = 63
  end
  

  def construct_draft
    until @approved
      attributes_hash = @template.set_draft_attributes(@timeFrame)
      @developer_template = "Hi #{attributes_hash['name']}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by #{attributes_hash['deadline']}
blah blah blah

Thanks!"

      @approved = @template.approval(@developer_template, @files)
    end
  end
end

#template = DeveloperTemplate.new
#template.construct_draft
