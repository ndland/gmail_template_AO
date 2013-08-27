require './spec/spec_helper'
require './designer_template'

describe DesignerTemplate do

  describe "#start" do
    before do
    @email = "test@atomicobject.com"
    @password = 'Ees5iShu'
    @name = "Test"
    @date = "2013-09-01 5:00pm"
    @deadline = " 8:00am EDT Wednesday Morning, September 4th"
    @attributes = Hash.new
    @attributes['name'] = @name
    @attributes['deadline'] = @deadline 
    @body = "hi #{@name}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline}
blah blah blah

Thanks!"

      Mail.defaults do
        retriever_method :imap, :address    => 'imap.gmail.com',
                                :port       => 993,
                                :user_name  => 'test@atomicobject.com',
                                :password   => 'Ees5iShu',
                                :enable_ssl => true
      end
      # subject.template = double("template", :start=> "true")
    end

    it "creates a new instance of the GmailTemplate class" do
      subject.template.should be_an_instance_of GmailTemplate
    end

    describe "#construct_draft" do

      it "calls gmailtemplate set_draft_attributes" do
        subject.template.stub(:approval).and_return(true)
        subject.template.should_receive(:set_draft_attributes).with(63 * 60 * 60).and_return(@attributes)
        subject.construct_draft
      end
    end
  end
end
