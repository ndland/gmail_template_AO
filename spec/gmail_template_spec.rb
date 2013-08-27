require './spec/spec_helper'
require './gmail_template'

describe GmailTemplate do
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

  describe "#approval" do
    it "calls ask to see if draft is ok" do
      subject.stub(:save_draft)
      subject.should_receive(:ask).with("#{@body_spec}\n\n Okay to send to Gmail as a draft? Y/N").and_return('y')
      subject.approval(@body_spec, [])
    end

    it "calls save_draft if draft was ok" do
      subject.stub(:ask).with("#{@body_spec}\n\n Okay to send to Gmail as a draft? Y/N").and_return('Y')
      subject.should_receive(:save_draft)
      subject.approval(@body_spec, [])
    end

    it "doesn't call save draft if draft wasn't ok" do
      subject.stub(:ask).and_return('N')
      subject.stub(:save_draft)
      subject.should_not receive(:save_draft)
      subject.approval(@body_spec, [])
    end

    it "passes in the body and the files to save_draft"do
      subject.stub(:ask).with("#{@body_spec}\n\n Okay to send to Gmail as a draft? Y/N").and_return('Y')
      subject.should_receive(:save_draft).with(@body_spec, [])
      subject.approval(@body_spec, [])
    end
  end

  describe "#set_draft_attributes" do
    before do
      subject.stub(:ask).with("What is the email address you'd like to send it to?").and_return(@email)
      subject.stub(:ask).with("What date would you like to send this email on?").and_return(@date)
      subject.stub(:ask).with("What is the name of the candidate?").and_return(@name_spec)
    end

    it "calls the ask function to set the email" do
      subject.should_receive(:ask).with("What is the email address you'd like to send it to?").and_return(@email)
      subject.set_draft_attributes(300)
    end
    it "calls the ask function to set the date" do
      subject.should_receive(:ask).with("What date would you like to send this email on?").and_return(@date)
      subject.set_draft_attributes(3000)
    end

    it "calls the ask function to set the date and time" do
      subject.should_receive(:ask).with("What is the name of the candidate?").and_return(@name_spec)
      subject.set_draft_attributes(30000)
    end

    it "calls the set_deadline function" do
      subject.should_receive(:set_deadline)
      subject.set_draft_attributes(2000)
    end

    it "returns a hash of the name and deadline" do
      attributes = subject.set_draft_attributes(3600*63)
      attributes['name'].should eq(@name_spec)
      attributes['deadline'].should eq(@deadline_spec)
    end
  end

  describe "#set_deadline" do

    it "sets the deadline based on what date was passed into the function" do
      subject.set_deadline('2013-09-01 5:00pm', 3600*63).should == '8:00am EDT Wednesday Morning, September 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      subject.set_deadline('2013-08-01 1:00pm', 3600*63).should == '4:00am EDT Sunday Morning, August 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      subject.set_deadline('2013-08-29 5:00pm', 3600*63).should == '8:00am EDT Sunday Morning, September 1st'
    end

    it "sets the deadline based on what timeframe was passed into the function" do
      subject.set_deadline('2013-08-29 5:00pm', 3600).should_not eq '8:00am EDT Sunday Morning, September 1st'
    end

    it "sets the deadline based on what timeframe was passed into the function" do
      subject.set_deadline('2013-08-29 5:00pm', 36000).should eq '3:00am EDT Friday Morning, August 30th'
    end
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
    end

    it "calls the logging_in method" do
      subject.should_receive(:logging_in)
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(3600 * 63)
      subject.imap = double("imap", :append => "true")
      subject.save_draft(@body_spec, [])
    end

    it "sends the draft to gmail" do
      draft_count = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).length
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(3600 * 63)
      subject.save_draft(@body_spec, [])
      draft_count.should_not eq(Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).length)
    end

    it "prints out that it was saved and prints out the send date" do
      STDOUT.should_receive(:puts).with("Draft successfully created. Please schedule to be sent at #{@date} " + "#{Time.parse(@date).zone}")
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.imap = double("imap", :append => "true")
      subject.set_draft_attributes(3600 * 63)
      subject.save_draft(@body_spec, [])
    end

    it 'has the correct email address' do
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(3600 * 63)
      subject.save_draft(@body_spec, [])
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
      drafts.to.should include(@email)
    end

    it 'inserts <br> instead of /n' do
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(3600 * 63)
      subject.save_draft(@body_spec, [])
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
      drafts.body.decoded.should include("hi #{@name_spec}!<br><br>Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline_spec}<br>blah blah blah<br><br>Thanks!")
    end

    it "adds a file to the email if given one" do
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(3600 * 63)
      subject.save_draft(@body_spec, ['./spec/spec_helper.rb'])
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
      drafts.attachments[0].filename.should eq 'spec_helper.rb'
    end

    it "doesnt add a file if there is none" do
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(3600 * 63)
      subject.save_draft(@body_spec, [])
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
      drafts.attachments.length.should eq 0
    end

    it "adds all the files" do
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(3600 * 63)
      subject.save_draft(@body_spec, ['./spec/spec_helper.rb', './spec/spec_helper.rb'])
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
      drafts.attachments.length.should eq 2
    end
  end

  describe "#logging_in" do

    it "asks for a username" do
      subject.stub(:ask).and_return(@password)
      subject.should_receive(:ask).with("What is your google username?").and_return(@email)
      subject.logging_in()
    end

    it "asks for a password" do
      subject.stub(:ask).and_return(@email)
      subject.should_receive(:ask).with("What is your google password?\n").and_return(@password)
      subject.logging_in()
    end

    it "it defines imap" do
      subject.stub(:ask).and_return(@email, @password)
      subject.logging_in()
      subject.imap.should be
    end

    it "it logs the use into google" do
      subject.stub(:ask).and_return(@email, @password)
      subject.logging_in()
      subject.imap.select("[Gmail]/Drafts")
    end

    it "calls logging_in again if the credentials are not correct" do
      subject.stub(:ask).with("What is your google username?").and_return("skjhf", @email)
      subject.stub(:ask).with("What is your google password?\n").and_return(@password)
      subject.logging_in()
      subject.imap.select("[Gmail]/Drafts")
    end
  end

  describe "ordinalize" do

    it "returns 1st when it recieves 1" do
      1.ordinalize.should eq('1st')
    end

    it "returns 2nd when it recieves 2" do
      2.ordinalize.should eq('2nd')
    end

    it "returns 33rd when it recieves 33" do
      33.ordinalize.should eq('33rd')
    end

    it "returns 12th when it recieves 12" do
      12.ordinalize.should eq('12th')
    end
  end
end

