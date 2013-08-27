require './gmail_template'

class DesignerTemplate

  attr_accessor :template, :developer_template
  def initialize
    @template = GmailTemplate.new
  end

  def construct_draft
    @template.set_draft_attributes(3600*63)
  end
end
