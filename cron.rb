require './app'

class Command
  def initialize
    @commands = []
    @target_dir = ''
  end

  def change_directory(target_dir)
    @target_dir = target_dir
    self
  end

  def grep(str)
    @commands << "grep -rn #{str} *"
    self
  end

  def line_count
    @commands << "wc -l"
    self
  end

  def run
    command = []
    command << "cd #{@target_dir}" if @target_dir
    command << @commands.join(" | ")
    `#{command.join(' && ')}`
  end
end

{
  "query utility" => Command.new.change_directory("~/Sites/rails/trada/marketplace").grep("QueryUtility").line_count.run,
  "env activerecord" => Command.new.change_directory("~/Sites/rails/trada/marketplace").grep("env_activerecord").line_count.run
}.each_pair do |report, result|
  Report.new(report).add(result)
end