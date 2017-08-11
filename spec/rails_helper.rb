# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

# @todo A more thorough RSpec configuration
