require './spec/spec_helper'
require './gmail_template'

describe GmailTemplate do
  before do
    @email = "nick.land@atomicobject.com"
    @name = "Nick Land"
    @date = "2013-09-01 5:00pm"
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

    it "calls the user_io function to set the email" do
      subject.stub(:gets) { @email }
      subject.should_receive(:user_io).exactly(3).and_return(@email)
      subject.set_draft_attributes
    end

    it "calls the user_io function to set the name" do
      subject.stub(:gets) { @name }
      subject.should_receive(:user_io).exactly(3).and_return(@name)
      subject.set_draft_attributes
    end

    it "calls the user_io function to set the date and time" do
      subject.stub(:gets) { @date }
      subject.should_receive(:user_io).exactly(3).and_return(@date)
      subject.set_draft_attributes
    end
  end

  # describe "#logging_in" do

  #   it "takes an email address and password" do
  #     subject.logging_in('adeline.miller@atomicobject.com', 'Ees5iShu')
  #   end

  #   it "it defines imap" do
  #     subject.logging_in('adeline.miller@atomicobject.com', 'Ees5iShu')
  #     subject.imap.should be
  #   end

  #   it "it logs the use into google" do
  #     subject.logging_in('adeline.miller@atomicobject.com', 'Ees5iShu')
  #     subject.imap.select("[Gmail]/Drafts")
  #   end

  #   it "returns false if the credentials are not correct" do
  #     subject.logging_in('adelne.miller@atomicobject.com', 'Ees5iShu').should be(false)
  #   end
  # end

  # describe "#sending draft" do
  #   it "

  # end
end
