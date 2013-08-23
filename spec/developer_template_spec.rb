require './spec/spec_helper'
require './developer_template'

describe DeveloperTemplate do

  describe "#start" do
    before do
    # @email = "test@atomicobject.com"
    # @password = 'Ees5iShu'
    # @name = "Test"
    # @date = "2013-09-01 5:00pm"
    # @deadline = " 8:00am EDT Wednesday Morning, September 4th"
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
      subject.start
      subject.template.should be_an_instance_of GmailTemplate
    end

    it "passes in the developer template into GmailTemplate" do
      subject.start
      subject.template.body.should eq(@body)
    end

    # it "" do
    #   drafts = Mail.find(:mailbox =>"[Gmail]/Drafts").length
    #   subject.start
    #   subject.template.ask("hi")
    #   #drafts.should_not eq(Mail.find(:mailbox =>"[Gmail]/Drafts").length)
    # end
  end
end
