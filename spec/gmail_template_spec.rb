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

  describe "#set_draft_attributes" do
    before do
      subject.stub(:ask).and_return(@email, @date, @name_spec)
      subject.stub(:set_deadline).and_return(@deadline_spec)
    end

    it "calls the ask function to set the email" do
      subject.should_receive(:ask).with("What is the email address you'd like to send it to?").and_return(@email)
      subject.set_draft_attributes(300)
    end

    it "calls the ask function to set the date" do
      subject.should_receive(:ask).with("What date would you like to send this email on? YYYY-MM-DD 12:00am\n").and_return(@date)
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
      attributes = subject.set_draft_attributes(63)
      attributes['name'].should eq(@name_spec)
      attributes['deadline'].should eq(@deadline_spec)
    end
  end

  describe "#set_deadline" do
    before do
      subject.stub(:time_of_day).and_return("Morning")
    end

    it "sets the deadline based on what date was passed into the function" do
      subject.set_deadline('2013-09-01 5:00pm', 63).should == '8:00am EDT Wednesday Morning, September 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      subject.set_deadline('2013-08-01 1:00pm', 63).should == '4:00am EDT Sunday Morning, August 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      subject.set_deadline('2013-08-29 5:00pm', 63).should == '8:00am EDT Sunday Morning, September 1st'
    end

    it "sets the deadline based on what timeframe was passed into the function" do
      subject.set_deadline('2013-08-29 5:00pm', 1).should_not eq '8:00am EDT Sunday Morning, September 1st'
    end

    it "sets the deadline based on what timeframe was passed into the function" do
      subject.set_deadline('2013-08-29 5:00pm', 10).should eq '3:00am EDT Friday Morning, August 30th'
    end

    it "sets the correct time zone" do
      subject.set_deadline('2013-02-02 5:00pm', 63).should == '8:00am EST Tuesday Morning, February 5th'
    end

    it "calls time_of_day" do
      subject.should_receive(:time_of_day)
      subject.set_deadline('2013-08-29 5:00pm', 36000)
    end

    it "inserts the time of day in the deadline" do
      subject.stub(:time_of_day).and_return("Evening")
      subject.set_deadline('2013-08-28 12:00pm', 34).should eq '10:00pm EDT Thursday Evening, August 29th'
    end
  end

  describe "#time_of_day" do
    it "returns morning for any time before noon" do
      subject.time_of_day(Time.parse('2013-08-29 5:00am')).should eq('Morning')
    end

    it "returns evening for any time after 6pm" do
      subject.time_of_day(Time.parse('2013-08-29 6:00pm')).should eq('Evening')
    end

    it "returns evening for any time between 6pm and 12am" do
      subject.time_of_day(Time.parse('2013-08-29 11:59pm')).should eq('Evening')
    end

    it "returns afternoon for any time between noon and 6pm" do
      subject.time_of_day(Time.parse('2013-08-29 5:59pm')).should eq('Afternoon')
    end

    it "returns afternoon for any time between noon and 6pm" do
      subject.time_of_day(Time.parse('2013-08-29 12:01pm')).should eq('Afternoon')
    end
  end

  describe "#approval" do
    before do
      subject.stub(:ask).and_return('Y')
    end

    after do
      subject.approval(@body_spec, [])
    end
    it "calls ask to see if draft is ok" do
      subject.stub(:get_credentials_and_save_draft)
      subject.should_receive(:ask).with("#{@body_spec}\n\n Okay to send to Gmail as a draft? Y/N").and_return('y')
    end

    it "calls save_draft if draft was ok" do
      subject.should_receive(:get_credentials_and_save_draft)
    end

    it "doesn't call save draft if draft wasn't ok" do
      subject.stub(:ask).and_return('N')
      subject.should_not receive(:get_credentials_and_save_draft)
    end

    it "passes in the body and the files to save_draft"do
      subject.should_receive(:get_credentials_and_save_draft).with(@body_spec, [])
    end
  end

  describe "#get_credentials_and_save_draft" do
    before do
      subject.stub(:ask).and_return(@email, @date, @name_spec, @email, @password)
      subject.set_draft_attributes(63)
      @credentials = {"user_name" => @email, "password" => @password}
      subject.stub(:get_credentials).and_return(@credentials)
      subject.stub(:save_draft).and_return(true)
    end

    after do
      subject.get_credentials_and_save_draft(@body_spec, [])
    end

    it "calls get_credentials" do
      subject.should_receive(:get_credentials)
    end

    it "calls save_draft" do
      subject.should_receive(:save_draft).once.with(@body_spec, [], @credentials).and_return(true)
    end

    it "calls save_draft until its successful" do
      subject.stub(:save_draft).twice.and_return(false, true)
    end

    it "prints out successful message when it succeeds" do
      subject.stub(:puts).with("Draft successfully created. Please schedule to be sent at #{@date} " + "#{Time.parse(@date).zone}")
    end

    it "returns true" do
      subject.get_credentials_and_save_draft(@body_spec, []).should eq true
    end
  end

  describe "#get_credentials" do
    before do
      subject.stub(:ask).and_return(@email, @password)
    end

    after do
      subject.get_credentials
    end

    it "asks for the username" do
      subject.should_receive(:ask).with("What is your google username?")
    end

    it "asks for a password" do
      subject.should_receive(:ask).with("What is your google password?\n").and_return(@password)
    end
    
    it "returns a hash of the credentials" do
      subject.get_credentials.should eq ({"user_name" => @email, "password" => @password})
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
      @credentials = {"user_name" => @email, "password" => @password}
      subject.stub(:ask).and_return(@email, @date, @name_spec)
      subject.set_draft_attributes(63)
    end

    it "it defines imap" do
      subject.save_draft(@body_spec, [], @credentials)
      subject.imap.should be
    end

    it "it logs the user into google" do
      subject.save_draft(@body_spec, [], @credentials)
      subject.imap.select("[Gmail]/Drafts")
    end

    it "sends the draft to gmail" do
      draft_count = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).length
      subject.save_draft(@body_spec, [], @credentials)
      draft_count.should_not eq(Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).length)
    end

    describe "#format_draft" do
      it 'has the correct email address' do
        subject.save_draft(@body_spec, [], @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.to.should include(@email)
      end

      it 'inserts <br> instead of /n' do
        subject.save_draft(@body_spec, [], @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.body.decoded.should include("hi #{@name_spec}!<br><br>Complete the problem presented in this...your resulting project should be sent to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline_spec}<br>blah blah blah<br><br>Thanks!")
      end

      it "adds a file to the email if given one" do
        subject.save_draft(@body_spec, ['./spec/spec_helper.rb'], @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.attachments[0].filename.should eq 'spec_helper.rb'
      end

      it "doesnt add a file if there is none" do
        subject.save_draft(@body_spec, [], @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.attachments.length.should eq 0
      end

      it "adds all the files" do
        subject.save_draft(@body_spec, ['./spec/spec_helper.rb', './spec/spec_helper.rb'], @credentials)
        drafts = Mail.find(:mailbox =>"[Gmail]/Drafts", :count=> :all).last
        drafts.attachments.length.should eq 2
      end

			it "deletes all the emails after the tests are done" do
        Mail.find_and_delete(:mailbox =>"[Gmail]/Drafts", :count=> :all)
			end

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
