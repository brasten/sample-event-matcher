require "json"

module EventMatching

  # Some made-up event
  class Event
    json_mapping({
      name: String,
      timestamp: Time,
      score: Float64,
      priority: Int32,
      subjects: Array(String)
    })


    def initialize( @name="",
                    @timestamp=Time.now,
                    @score=0.0,
                    @priority=2,
                    @subjects=[] of String ); end

  end
end
