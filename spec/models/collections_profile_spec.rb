# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsProfile, type: :model do
  context 'with an empty object' do
    subject { described_class.new }

    its(:name) { is_expected.to be_nil }
    its(:run_id) { is_expected.to be_nil }
    its(:total) { is_expected.to be_nil }
    its(:wait) { is_expected.to be_nil }
    its(:child) { is_expected.to be_nil }
    its(:calls) { is_expected.to be_nil }
    its(:percent_self) { is_expected.to be_nil }
    its(:self) { is_expected.to be_nil }
  end

  context 'with a created object' do
    subject do
      described_class.create(
        name: 'method_call',
        run_id: 1,
        total: 1.2,
        wait: 1.1,
        child: 0.4,
        calls: 10,
        percent_self: 10.3,
        self: 9.1
      )
    end

    its(:name) { is_expected.to eq('method_call') }
    its(:run_id) { is_expected.to eq(1) }
    its(:total) { is_expected.to eq(1.2) }
    its(:wait) { is_expected.to eq(1.1) }
    its(:child) { is_expected.to eq(0.4) }
    its(:calls) { is_expected.to eq(10) }
    its(:percent_self) { is_expected.to eq(10.3) }
    its(:self) { is_expected.to eq(9.1) }
  end
end
