require 'spec_helper'
require File.expand_path(File.dirname(__FILE__ ) + '/../backfill')

describe Backfill do
  describe "#new" do
    subject do
      Backfill.new('hello_instances', "30", 'grep "hello"')
    end

    it "should take the name of the report" do
      subject.name.should == 'hello_instances'
    end

    it "should take how many days to go back" do
      subject.days.should == 30
    end

    it "should take what command to run each day" do
      subject.command.should == 'grep "hello"'
    end
  end

  describe "#run" do
    it "should run the command for each day" do
      backfill = Backfill.new('hello_instances', 1, 'grep "hello"')

      backfill.stub(:execute_command => nil)

      Report.should_receive(:new).with('hello_instances', [hash_including(date: Date.today.to_s)]).once

      backfill.run
    end

    it "should go back in time (in the repo)" do
      backfill = Backfill.new('hello_instances', 2, 'grep "hello"')
      backfill.stub(:execute_command => nil)

      backfill.should_receive(:execute_command).with("git log --until='0 days ago' -n 1 --format='%H'").ordered.and_return(123456123455123123)
      backfill.should_receive(:execute_command).with('git checkout 123456123455123123').ordered.and_return('')
      backfill.should_receive(:execute_command).with('grep "hello"').ordered.and_return(30)
      Report.should_receive(:new).with('hello_instances', [hash_including(date: Date.today.to_s, y: 30)]).ordered

      backfill.should_receive(:execute_command).with("git log --until='1 days ago' -n 1 --format='%H'").ordered.and_return(123456123455123123)
      backfill.should_receive(:execute_command).with('git checkout 123456123455123123').ordered.and_return('')
      backfill.should_receive(:execute_command).with('grep "hello"').ordered.and_return(70)
      Report.should_receive(:new).with('hello_instances', [hash_including(date: days_ago_string(1), y: 70)]).ordered

      backfill.run
    end
  end

  def days_ago_string(days)
    (Time.now - (days * 24 * 60 * 60)).strftime("%Y-%m-%d")
  end
end