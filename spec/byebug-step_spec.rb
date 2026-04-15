require 'byebug'
require 'capybara/rspec'

Capybara.default_driver = :selenium

RSpec.describe Byebug, type: :system do
  it "steps correctly" do
    visit "https://runephilosof-abtion.github.io/byebug-step-example"
    byebug
    check "some"

    visit "https://runephilosof-abtion.github.io/byebug-step-example"
    check "some"
  end
end
