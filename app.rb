require 'rubygems'
require 'sinatra/base'
require 'redis'
require 'json'

module Racker
  def self.redis
    Redis.new
  end
end

class Report
  def self.all
    Racker.redis.smembers("reports").map do |report|
      json = Racker.redis.lrange(report, 0, -1).collect do |json|
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
    Racker.redis.lrange(@name, 0, -1).collect do |redis_data|
      JSON(redis_data)
    end
  end

  def add(datum)
    Racker.redis.lpush(name, JSON.generate(datum))
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