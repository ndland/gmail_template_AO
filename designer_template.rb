require './gmail_template'

class DesignerTemplate

  attr_accessor :template, :designer_template
  def initialize
    @template = GmailTemplate.new
  end

  def construct_draft
    approved = false
    files = ['./spec/spec_helper.rb']
    until approved
      attributes_hash = @template.set_draft_attributes(3600*63)
      @designer_template = "hi #{attributes_hash['name']}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{attributes_hash['deadline']}
blah blah blah

Thanks!"
      approved = @template.approval(@designer_template, files)
    end
  end
end

=begin
def construct_draft
approved = false
  until approved
attributes_hash = @template.set_draft_attributes(3600*63)
  @developer_template = "hi #{attributes_hash['name']}!

  Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{attributes_hash['deadline']}
  blah blah blah

  Thanks!"

approved = @template.approval(@developer_template, [])
  end
  end
  end
=end

#DeveloperTemplate.new.construct_draft
# construct_draft
