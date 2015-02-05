module EventMatching

  # Contains a set of patterns
  #
  class PatternSet
    def initialize
      @set = [] of Pattern
    end

    # Add a pattern to this PatternSet.
    #
    # @param name of pattern
    # @param rule_bits the particular set of rules that have to match
    #                  for this pattern to match.
    #
    def add(name : Symbol, rule_bits : Rule::MatchType)
      @set << Pattern.new(name, rule_bits)
    end

    # Returns the patterns that are satisfied by the provided bits
    #
    # @param [Rule::MatchType] match
    # @return list of Patterns
    #
    def for(matches)
      @set.select(&.is_satisfied?(matches)).map(&.name)
    end
  end

  class Pattern
    getter :name

    def initialize(@name, @bits); end

    def is_satisfied?(matches)
      (matches & @bits) == @bits
    end
  end
end
