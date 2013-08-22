require './spec/spec_helper'
require './gmail_template'

describe GmailTemplate do
  before do
    @email = "test@atomicobject.com"
    @password = 'Ees5iShu'
    @name = "Test"
    @date = "2013-09-01 5:00pm"
    @deadline = " 8am EDT Wednesday Morning, September 4th"
    @body = "hi #{@name}!

Complete the problem presented in this...your resulting project to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline}
blah blah blah

Thanks!"
  end

  describe "#start" do
    before do
      subject.stub(:user_io).with("What is the email address you'd like to send it to?").and_return(@email)
      subject.stub(:user_io).with("What date would you like to send this email on?").and_return(@date)
      subject.stub(:user_io).with("What is the name of the candidate?").and_return(@name)
    end

    it "calls the construct_draft function" do
      subject.stub(:user_io).and_return('Y')
      subject.should_receive(:construct_draft).at_least(1).times
      subject.stub(:save_draft)
      subject.start
    end

    it "calls user_io to see if draft is ok" do
      subject.stub(:save_draft)
      subject.should_receive(:user_io).with("#{@body}\n\n Okay to send to Gmail as a draft? Y/N").and_return('Y')
      subject.start
    end

    it "calls save_draft if draft was ok" do
      subject.stub(:user_io).with("#{@body}\n\n Okay to send to Gmail as a draft? Y/N").and_return('Y')
      subject.should_receive(:save_draft)
      subject.start
    end

    it "calls construct_draft if draft was not ok" do
      subject.stub(:user_io).and_return('N', 'Y')
      subject.stub(:save_draft)
      subject.should_receive(:construct_draft).twice
      subject.start
    end
  end

  describe "#construct_draft" do
    before do
      subject.stub(:user_io).and_return(@email, @date, @name)
    end

    it "calls the set_draft_attributes function" do
      subject.should_receive(:set_draft_attributes)
      subject.construct_draft
    end

    it "constructs the body" do
      subject.construct_draft
      subject.body.should eq(@body)
    end
  end

  describe "#user_io" do

    it "prompts the user for an email address to send the email to" do
      subject.stub(:gets) { @email }
      STDOUT.should_receive(:puts).with("What is the email address you'd like to send it to?")
      subject.user_io("What is the email address you'd like to send it to?")
    end

    it "takes user input to answer the questions that are passsed to it" do
      subject.stub(:gets) { @email }
      STDOUT.should_receive(:puts).with("What is the email address you'd like to send it to?")
      subject.user_io("What is the email address you'd like to send it to?").should == @email
    end

    it "prompts the user for the name of the candidate" do
      subject.stub(:gets) { @name }
      STDOUT.should_receive(:puts).with("What is the name of the candidate?")
      subject.user_io("What is the name of the candidate?")
    end

    it "takes user input to answer the questions that are passsed to it" do
      subject.stub(:gets) { @name }
      STDOUT.should_receive(:puts).with("What is the name of the candidate?")
      subject.user_io("What is the name of the candidate?").should == @name
    end

    it "prompts the user for the date to send the email on" do
      subject.stub(:gets) { @date }
      STDOUT.should_receive(:puts).with("What date would you like to send this email on?")
      subject.user_io("What date would you like to send this email on?")
    end

    it "takes user input to answer the questions that are passsed to it" do
      subject.stub(:gets) { @date }
      STDOUT.should_receive(:puts).with("What date would you like to send this email on?")
      subject.user_io("What date would you like to send this email on?").should == @date
    end
  end

  describe "#set_draft_attributes" do
    before do
      subject.stub(:user_io).with("What is the email address you'd like to send it to?").and_return(@email)
      subject.stub(:user_io).with("What date would you like to send this email on?").and_return(@date)
      subject.stub(:user_io).with("What is the name of the candidate?").and_return(@name)
    end

    it "calls the user_io function to set the email" do
      subject.should_receive(:user_io).with("What is the email address you'd like to send it to?").and_return(@email)
      subject.set_draft_attributes
    end

    it "calls the user_io function to set the date" do
      subject.should_receive(:user_io).with("What date would you like to send this email on?").and_return(@date)
      subject.set_draft_attributes
    end

    it "calls the user_io function to set the date and time" do
      subject.should_receive(:user_io).with("What is the name of the candidate?").and_return(@name)
      subject.set_draft_attributes
    end

    it "calls the set_deadline function" do
      subject.should_receive(:set_deadline)
      subject.set_draft_attributes
    end
  end

  describe "#set_deadline" do

    it "sets the deadline based on what date was passed into the function" do
      subject.stub(:gets) { @date }
      subject.set_deadline('2013-09-01 5:00pm').should == '8am EDT Wednesday Morning, September 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      subject.stub(:user_io).with("What date would you like to send this email on?").and_return(@date)
      subject.set_deadline('2013-08-01 1:00pm').should == '4am EDT Sunday Morning, August 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      subject.stub(:user_io).with("What date would you like to send this email on?").and_return(@date)
      subject.set_deadline('2013-08-29 5:00pm').should == '8am EDT Sunday Morning, September 1st'
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
      subject.stub(:user_io).and_return(@email, @date, @name, 'Y', @email)
      subject.stub(:ask).and_return(@password)
      subject.imap = double("imap", :append => "true")
      subject.start
    end

    it "sends the draft to gmail" do
      subject.stub(:user_io).and_return(@email)
      subject.stub(:ask).and_return(@password)
      subject.logging_in()
      subject.imap.select("[Gmail]/Drafts")
      draft_count = subject.imap.status("[Gmail]/Drafts", ["MESSAGES"])
      subject.stub(:user_io).and_return(@email, @date, @name, 'Y', @email)
      subject.start
      subject.imap.status("[Gmail]/Drafts", ["MESSAGES"]).should_not eq(draft_count)
    end

    it "prints out that it was saved and prints out the send date" do
      STDOUT.should_receive(:puts).with("Draft successfully created. Please schedule to be sent at #{@date} " + "#{Time.parse(@date).zone}")
      subject.stub(:user_io).and_return(@email, @date, @name, 'Y', @email, @password)
      subject.stub(:ask).and_return(@password)
      subject.imap = double("imap", :append => "true")
      subject.start
    end

    it 'has the correct email address' do
      subject.stub(:user_io).and_return(@email, @date, @name, 'Y', @email, @password)
      subject.stub(:ask).and_return(@password)
      subject.start
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts").last
      drafts.to.should include(@email)
    end

    it 'inserts <br> instead of /n' do
      subject.stub(:user_io).and_return(@email, @date, @name, 'Y', @email, @password)
      subject.stub(:ask).and_return(@password)
      subject.start
      drafts = Mail.find(:mailbox =>"[Gmail]/Drafts").last
      drafts.body.decoded.should include("hi #{@name}!<br><br>Complete the problem presented in this...your resulting project to us at <a href =\"mailto: detroit.jobs@atomicobject.com\">detroit.jobs@atomicobject.com</a> by#{@deadline}<br>blah blah blah<br><br>Thanks!")
    end
  end

  describe "#logging_in" do

    it "asks for a username" do
      subject.stub(:ask).and_return(@password)
      subject.should_receive(:user_io).with("What is your google username?").and_return(@email)
      subject.logging_in()
    end

    it "asks for a password" do
      subject.stub(:user_io).and_return(@email)
      subject.should_receive(:ask).with("What is your google password?\n").and_return(@password)
      subject.logging_in()
    end

    it "it defines imap" do
      subject.stub(:user_io).and_return(@email)
      subject.stub(:ask).and_return(@password)
      subject.logging_in()
      subject.imap.should be
    end

    it "it logs the use into google" do
      subject.stub(:user_io).and_return(@email)
      subject.stub(:ask).and_return(@password)
      subject.logging_in()
      subject.imap.select("[Gmail]/Drafts")
    end

    it "calls logging_in again if the credentials are not correct" do
      subject.stub(:user_io).with("What is your google username?").and_return("skjhf", @email)
      subject.stub(:ask).with("What is your google password?\n").and_return(@password)
      subject.logging_in()
      subject.imap.select("[Gmail]/Drafts")
    end
  end
end
