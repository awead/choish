# frozen_string_literal: true

class Travis
  class << self
    def present?
      ENV.fetch('TRAVIS', false)
    end
  end
end

RSpec.configure do |config|
  config.filter_run_excluding broken_in_travis: true
end
