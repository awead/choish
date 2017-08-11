# frozen_string_literal: true

# Generated with `rails generate valkyrie:model Cho::Collection`
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Collection do
  subject { collection }

  let(:resource_klass) { described_class }
  let(:collection) { described_class.new }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#title' do
    before { collection.title = 'My Title' }
    its(:title) { is_expected.to eq(['My Title']) }
  end

  describe '#description' do
    before { collection.description = 'some description' }
    its(:description) { is_expected.to eq(['some description']) }
  end

  describe '#member_ids' do
    before { collection.member_ids = [1, 2, 3] }
    its(:member_ids) { is_expected.to eq([1, 2, 3]) }
  end
end
