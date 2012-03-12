require 'rubygems'
require 'sinatra/base'
require 'redis'
require 'json'

module Racker
  def self.redis
    uri = URI.parse(ENV["REDISTOGO_URL"] || 'localhost')
    @redis ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end
end

class Report
  def self.all
    Racker.redis.smembers("reports").map do |report|
      json = Racker.redis.smembers(report).collect do |json|
        JSON.parse(json)
      end

      Report.new(report, json)
    end
  end


  attr_reader :name

  def initialize(name, data = [])
    @name = name

    Racker.redis.sadd("reports", name)
    data.each do |datum|
      add(datum)
    end
  end

  def data
    Racker.redis.smembers(@name).collect do |redis_data|
      JSON(redis_data)
    end
  end

  def add(datum)
    if datum.kind_of?(Numeric) || datum.kind_of?(String)
      datum = {date: Date.today, y: datum.to_s.strip}
    end

    Racker.redis.sadd(name, JSON.generate(datum))
  end

  def to_morris_data
    "[" + Array(data).map{|json| "{x: '#{json['date']}', y: #{json['y']}}"}.join(",") + "]"
  end

  def data_paired_with_date
    data
  end
end

class App < Sinatra::Base

  dir = File.dirname(File.expand_path(__FILE__))

  set :views,  "#{dir}/views"
  set :public_folder, "#{dir}/public"

  get '/' do
    @reports = Report.all

    erb :index
  end

  get '/stats/:stat' do
    @stats = Racker.redis.smember
  end
end