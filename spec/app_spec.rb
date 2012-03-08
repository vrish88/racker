require 'spec_helper'
require 'rack/test'
require 'racker'

describe "App" do
  include Rack::Test::Methods

  def app
    @app ||= App
  end

  before(:each) { Redis.new.flushall }

  it "should respond to /" do
    get '/'

    last_response.should be_successful
  end
end

describe Report do
  before(:each) { Racker.redis.flushall }

  it 'expects each report to be the "reports" list' do
    Report.new("temp")

    Racker.redis.sismember("reports", "temp").should be_true
  end

  describe ".new" do
    it 'should store the name' do
      Report.new("temp")

      Racker.redis.sismember("reports", "temp").should be_true
    end
  end

  describe '#data' do
    it 'should get all the data in the list with the most recent first' do
      report = Report.new("temp", [{date: "2012-01-01", y: 1}, {date: "2012-01-02", y: 12}])

      report.data.should == [{"date" => "2012-01-02", "y" => 12}, {"date" => "2012-01-01", "y" => 1}]
    end
  end

  describe "#add" do
    it "should append the data point to the front of the list" do
      report = Report.new("temp", [{date: "2012-01-01", y: 1}])

      report.add({date: "2012-01-02", y: 2})

      report.data.should == [{"date" => "2012-01-02", "y" => 2}, {"date" => "2012-01-01", "y" => 1}]
    end

    it "should convert date objects to YYYY-MM-DD" do
      report = Report.new("temp")

      report.add({date: Date.today, y: 2})

      report.data.should == [{"date" => Date.today.strftime("%Y-%m-%d"), "y" => 2}]
    end

    it "should convert a number into a hash with today's date for storage" do
      report = Report.new("temp")

      report.add(2)

      report.data.should == [{"date" => Date.today.strftime("%Y-%m-%d"), "y" => 2}]
    end
  end

  describe '#data_paired_with_date' do
    it 'should assign yesterday with the first data point in the list' do
      report = Report.new("temp", [{date: "2012-01-01", y: 1}])

      report.data.first.should == {"date" => "2012-01-01", "y" => 1}
    end
  end
end