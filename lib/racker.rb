require 'json'
require 'active_support'
require '../app'

module Racker
  def self.redis
    Redis.new
  end
end