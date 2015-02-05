require "./spec_helper"

module EventMatching

  describe "EventMatching process" do

    it "returns matching patterns" do
      # Pre-generation phase
      #
      rules = RuleSet.new
      rules.add(:critical)  { |ev| ev.score > 0.9 }
      rules.add(:danger)    { |ev| ev.score > 0.7 }
      rules.add(:offscale)  { |ev| ev.score < 0.1 }
      rules.add(:score_normal_range) do |ev|
        # this rule matches when the other three score rules fail to match
        !rules.match_rule?(:critical, ev) &&
          !rules.match_rule?(:danger, ev) &&
          !rules.match_rule?(:offscale, ev)
      end

      rules.add(:core_event)         { |ev| ev.name == "core" }
      rules.add(:breach_event)       { |ev| ev.name == "breach" }
      rules.add(:atmospheric_event)  { |ev| ev.name == "atmospheric"}
      rules.add(:hostility_event)    { |ev| ev.name == "hostility" || ev.name == "breach" }

      rules.add(:involves_octospiders) { |ev| (ev.subjects || [] of String).includes?("octospiders") }
      rules.add(:involves_humans)      { |ev| (ev.subjects || [] of String).includes?("humans") }
      rules.add(:involves_avians)      { |ev| (ev.subjects || [] of String).includes?("avians") }


      # Build patterns
      patterns = PatternSet.new
      patterns.add :hibernation_threshold,
        rules.mask_for(:critical, :hostility_event, :involves_octospiders,
                       :involves_humans, :involves_avians)

      patterns.add :human_belligerents,
        rules.mask_for(:danger, :hostility_event, :involves_humans)

      patterns.add :avian_belligerents,
        rules.mask_for(:danger, :hostility_event, :involves_avians)

      patterns.add :isolation_breach,
        rules.mask_for(:danger, :breach_event)
        

      #--- Test actual logic ---#

      # Humans and avians fighting again.
      ha_results =
        rules.matches( Event.new(subjects: ["humans", "avians"],
                               name: "hostility",
                               score: 0.7132) )

      ha_patterns = patterns.for(ha_results)

      ha_patterns.includes?(:human_belligerents).should be_true
      ha_patterns.includes?(:avian_belligerents).should be_true
      ha_patterns.size.should eq(2)


      # Octospiders breach

      ob_results =
        rules.matches( Event.new(subjects: ["humans", "octospiders"],
                                 name: "breach",
                                 score: 0.991) )

      ob_patterns = patterns.for(ob_results)

      ob_patterns.includes?(:human_belligerents).should be_true
      ob_patterns.includes?(:isolation_breach).should be_true
      ob_patterns.size.should eq(2)

    end
  end
end
