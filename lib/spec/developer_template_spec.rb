require './lib/spec/spec_helper'
require './developer_template'

describe DeveloperTemplate do

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
    @subject = "developer challenge"
    @body = "Hi #{@name}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by #{@deadline}
blah blah blah

Thanks!"

      Mail.defaults do
        retriever_method :imap, :address    => 'imap.gmail.com',
                                :port       => 993,
                                :user_name  => 'test@atomicobject.com',
                                :password   => 'Ees5iShu',
                                :enable_ssl => true
      end
    end

    it "creates a new instance of the GmailTemplate class" do
      subject.template.should be_an_instance_of ChallengeCli
    end

    describe "#construct_draft" do
      it "calls gmailtemplate set_draft_attributes" do
        subject.template.stub(:approval).and_return(true)
        subject.template.should_receive(:set_draft_attributes).with(63).and_return(@attributes)
        subject.construct_draft
      end

      it "sets developer_template to equal body" do
        subject.template.stub(:approval).and_return(true)
        subject.template.stub(:set_draft_attributes).and_return(@attributes)
        subject.construct_draft
        subject.developer_template.should eq(@body)
      end

      it "dynamically sets developer_template to equal body" do
        @name = 'adeline'
        @attributes['name'] = @name
        @body = "Hi #{@name}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by #{@deadline}
blah blah blah

Thanks!"
        subject.template.stub(:approval).and_return(true)
        subject.template.stub(:set_draft_attributes).and_return(@attributes)
        subject.construct_draft
        subject.developer_template.should eq(@body)
      end

      it "asks the user for approval before saving the email" do
          subject.template.stub(:set_draft_attributes).and_return(@attributes)
          subject.template.should_receive(:approval).once.and_return(true)
          subject.construct_draft
      end

      it "constructs the draft again if it doesnt receive approval" do
          subject.template.should_receive(:set_draft_attributes).twice.and_return(@attributes)
          subject.template.stub(:approval).and_return(false, true)
          subject.construct_draft
      end

      it "calls the approval method with three parameters" do
          subject.template.stub(:set_draft_attributes).and_return(@attributes)
          subject.template.should_receive(:approval).once.with(@body, @subject, []).and_return(true)
          subject.construct_draft
      end
    end

    it "adds a new email" do
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts").length
      subject.template.stub(:ask).and_return(@email, @date, @name, 'Y', @email, @password)
      subject.construct_draft
      drafts.should_not eq(Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).length)
    end
  end
end
