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

    it "calls the ask function to set the email" do
      subject.stub(:ask).and_return(@date, @name_spec)
      subject.should_receive(:ask).with("What is the email address you'd like to send it to?").and_return(@email)
      subject.set_draft_attributes(300)
    end

    it "calls the ask function to set the date" do
      subject.stub(:ask).and_return(@email, @name_spec)
      subject.should_receive(:ask).with("What date would you like to send this email on? YYYY-MM-DD 12:00am\n").and_return(@date)
      subject.set_draft_attributes(3000)
    end

    it "calls the ask function to set the name" do
      subject.stub(:ask).and_return(@email, @date)
      subject.should_receive(:ask).with("What is the name of the candidate?").and_return(@name_spec)
      subject.set_draft_attributes(30000)
    end

    it "creates a deadline" do
			Deadline.should_receive(:new).and_call_original
      subject.stub(:ask).and_return(@email, @date, @name_spec)
      subject.set_draft_attributes(2000)
    end

    it "returns a hash of the name and deadline" do
      subject.stub(:ask).and_return(@email, @date, @name_spec)
      attributes = subject.set_draft_attributes(63)
      attributes['name'].should eq(@name_spec)
      attributes['deadline'].should eq(@deadline_spec)
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
			subject.draft.stub(:save_draft)
			subject.draft.stub(:successful).and_return(true)
    end

    after do
      subject.get_credentials_and_save_draft(@body_spec, [])
    end

    it "calls get_credentials" do
      subject.should_receive(:get_credentials)
    end

    it "calls save_draft" do
      subject.draft.should_receive(:save_draft).once.with(@body_spec, [], @email, @credentials)
    end

    it "calls save_draft until its successful" do
			subject.draft.stub(:successful).and_return(false, true)
      subject.draft.should_receive(:save_draft).twice.with(@body_spec, [], @email, @credentials)
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
