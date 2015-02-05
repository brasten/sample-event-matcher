require "./event"

typeof(EventMatching::Event.new)  # ? Not sure why this is necessary. Crystal compiler issue?

module EventMatching

  class RuleSet
    def initialize
      @registry = {} of Symbol => Rule
    end

    # Adds a rule to the registry. Returns an instance of Rule.
    #
    # @param [Symbol] name
    # @param [Event -> Boolean] block
    # @return Rule
    #
    def add(name, &block : Event -> Boolean)
      rule = Rule.new(@registry.keys.size, &block)
      @registry[name] = rule
      rule
    end

    def match_rule?(name : Symbol, event : Event)
      rule = @registry[name]

      rule.nil? ? false : rule.match?(event)
    end

    # SRP violation ...
    # @param [Event]
    # @return matches (bit array)
    #
    def matches(event)
      arr = 0 as Rule::MatchType

      rules.each do |rule|
        if rule.match?(event)
          arr |= (1 << rule.id)
        end
      end

      arr
    end

    # Returns a bit array used to indicate matching rules
    #
    def mask_for(*rules)
      arr = 0 as Rule::MatchType

      rules.each do |n|
        pos = (@registry[n] as Rule).id
        arr |= (1 << pos)
      end

      arr
    end

    private def rules
      @registry.values
    end
  end

  class Rule
    alias MatchType = Int32

    getter :id

    def initialize(@id, &@expression : Event -> Boolean); end

    def match?(event : Event)
      @expression.call(event)
    end
  end

end
