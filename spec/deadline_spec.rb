require './spec/spec_helper'
require './deadline'

describe Deadline do
  describe "#set_deadline" do
    before do
    end

    it "sets the deadline based on what date was passed into the function" do
      Deadline.new('2013-09-01 5:00pm', 63).value.should == '8:00am EDT Wednesday Morning, September 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      Deadline.new('2013-08-01 9:00pm', 63).value.should == '12:00pm EDT Sunday Afternoon, August 4th'
    end

    it "sets the deadline based on what date was passed into the function" do
      Deadline.new('2013-08-30 3:00am', 63).value.should == '6:00pm EDT Sunday Evening, September 1st'
    end

    it "sets the deadline based on what timeframe was passed into the function" do
      Deadline.new('2013-08-29 5:00pm', 1).value.should_not eq '8:00am EDT Sunday Morning, September 1st'
    end

    it "sets the deadline based on what timeframe was passed into the function" do
      Deadline.new('2013-08-29 5:00pm', 10).value.should eq '3:00am EDT Friday Morning, August 30th'
    end

    it "sets the correct time zone" do
      Deadline.new('2013-02-02 5:00pm', 63).value.should == '8:00am EST Tuesday Morning, February 5th'
    end

    it "inserts the time of day in the deadline" do
      Deadline.new('2013-08-28 12:00pm', 34).value.should eq '10:00pm EDT Thursday Evening, August 29th'
    end
  end
end
