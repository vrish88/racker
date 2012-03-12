class Backfill
  attr_reader :days
  attr_reader :command
  attr_reader :name

  def initialize(name, days, command)
    @days = days.to_i
    @command = command
    @name = name
  end

  def run
    days.times do |day_ago|
      end_of_day_hash = execute_command("git log --until='#{day_ago} days ago' -n 1 --format='%H'")
      execute_command("git checkout #{end_of_day_hash}")
      result = execute_command(command)

      Report.new(name, [date: days_ago_string(day_ago), y: result])
    end
  end

  private

  def days_ago_string(days)
    (Time.now - (days * 24 * 60 * 60)).strftime("%Y-%m-%d")
  end

  def execute_command(command_to_run)
    `#{command_to_run}`
  end
end

if __FILE__ == $0
  puts 'executing'
  require File.expand_path(File.dirname(__FILE__ ) + '/app')

  Backfill.new(*ARGV).run
end