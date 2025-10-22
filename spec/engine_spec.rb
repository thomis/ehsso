require "spec_helper"

RSpec.describe "Rails Engine" do
  context "when Rails is available" do
    it "defines an engine class" do
      # We can't easily test the conditional loading without Rails fully loaded
      # But we can verify that if we manually require rails and the engine,
      # the Engine class is properly defined

      # Since Rails is available in our test environment (as a dev dependency),
      # let's just verify the engine can be loaded
      require "rails"
      require "ehsso/engine"

      expect(defined?(Ehsso::Engine)).to be_truthy
      expect(Ehsso::Engine.ancestors).to include(Rails::Engine)
    end

    it "loads engine through main file when Rails is defined" do
      # First ensure Rails is loaded
      require "rails"

      # Remove Ehsso from loaded features to allow reloading
      $LOADED_FEATURES.delete_if { |f| f.include?("lib/ehsso.rb") }

      # Now reload ehsso.rb - this time Rails::Engine is defined,
      # so it should execute the conditional require
      load File.expand_path("../../lib/ehsso.rb", __FILE__)

      expect(defined?(Ehsso::Engine)).to be_truthy
    end
  end
end
