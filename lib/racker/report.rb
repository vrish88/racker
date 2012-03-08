class Report
  def self.all
    Racker.redis.hgetall("reports").map do |report|
      name, data = report
      Report.new(name, JSON.parse(data))
    end
  end


  attr_reader :name
  attr_reader :data

  def initialize(name, data)
    @name = name
    @data = data
  end
end