require 'spec_helper'

describe Report do
  before(:each) { Racker.redis.flushall }

  describe '.all' do
    it 'should return all reports and daily stats' do
      Racker.redis.hset(
          "reports",
          "query utility",
          JSON({
              :data => {
                  '2012-01-01' => 123,
                  '2012-01-02' => 124,
                  '2012-01-03' => 125,
                  '2012-01-04' => 126
              }
          })
      )

      Report.all.first.data == {
          '2012-01-01' => 123,
          '2012-01-02' => 124,
          '2012-01-03' => 125,
          '2012-01-04' => 126
      }
    end
  end
end