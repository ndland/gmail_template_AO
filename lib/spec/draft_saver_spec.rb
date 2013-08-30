require './lib/spec/spec_helper'
require './lib/draft_saver'

describe Draft_saver do
  before do
    @email = "test@atomicobject.com"
    @password = 'Ees5iShu'
    @name_spec = "Test"
    @date = "2013-09-01 5:00pm"
    @deadline_spec = "8:00am EDT Wednesday Morning, September 4th"
    @body_spec = "hi #{@name_spec}!

Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline_spec}
blah blah blah

Thanks!"
  end
  describe "#save_draft" do
    before do
      Mail.defaults do
        retriever_method :imap, :address    => 'imap.gmail.com',
                                :port       => 993,
                                :user_name  => 'test@atomicobject.com',
                                :password   => 'Ees5iShu',
                                :enable_ssl => true
      end
      @credentials = {"user_name" => @email, "password" => @password}
    end

    it "it defines imap" do
      subject.save_draft(@body_spec, [], @email, @credentials)
      subject.imap.should be
    end

    it "it logs the user into google" do
      subject.save_draft(@body_spec, [], @email, @credentials)
      subject.imap.select("[Gmail]/Drafts")
    end

    it "sends the draft to gmail" do
      draft_count = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).length
      subject.save_draft(@body_spec, [], @email, @credentials)
      draft_count.should_not eq(Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).length)
    end

    describe "#format_draft" do
      it 'has the correct email address' do
        subject.save_draft(@body_spec, [], @email, @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.to.should include(@email)
      end

      it 'inserts <br> instead of /n' do
        subject.save_draft(@body_spec, [], @email, @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.body.decoded.should include("hi #{@name_spec}!<br><br>Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline_spec}<br>blah blah blah<br><br>Thanks!")
      end

      it "adds a file to the email if given one" do
        subject.save_draft(@body_spec, ['./lib/spec/spec_helper.rb'], @email, @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.attachments[0].filename.should eq 'spec_helper.rb'
      end

      it "doesnt add a file if there is none" do
        subject.save_draft(@body_spec, [], @email, @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.attachments.length.should eq 0
      end

      it "adds all the files" do
        subject.save_draft(@body_spec, ['./lib/spec/spec_helper.rb', './lib/spec/spec_helper.rb'], @email, @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.attachments.length.should eq 2
      end

			it "deletes all the emails after the tests are done" do
        Mail.find_and_delete(:mailbox =>"[Gmail]/Drafts", :count=> :all)
			end

    end
  end
end
