require './lib/challenge_cli'

class DeveloperTemplate

  attr_accessor :template, :developer_template

  def initialize
    @template = ChallengeCli.new
    @approved = false
    @files = []
    @subject = "developer challenge"
    @timeFrame = 63
  end

  def construct_draft
    until @approved
      attributes_hash = @template.set_draft_attributes(@timeFrame)#attributes hash = name & deadline
      @developer_template = "Hi #{attributes_hash['name']}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by #{attributes_hash['deadline']}
blah blah blah

Thanks!"

      @approved = @template.approval(@developer_template, @subject, @files)
    end
  end
end

template = DeveloperTemplate.new
template.construct_draft
