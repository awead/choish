# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Choish::File do
  subject { described_class.open('spec/fixtures/small_random.bin', 'r') }

  describe '#original_filename' do
    its(:original_filename) { is_expected.to eq('small_random.bin') }
  end
end
