# frozen_string_literal: true

require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Work do
  subject { work }

  let(:resource_klass) { described_class }
  let(:work) { described_class.new }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#title' do
    before { work.title = 'My Title' }
    its(:title) { is_expected.to eq(['My Title']) }
  end

  describe '#description' do
    before { work.description = 'some description' }
    its(:description) { is_expected.to eq(['some description']) }
  end

  describe '#keywords' do
    before { work.keywords = ['foo'] }
    its(:keywords) { is_expected.to eq(['foo']) }
  end

  describe '#part_of_collections' do
    before { work.part_of_collections = 1 }
    its(:part_of_collections) { is_expected.to eq([1]) }
  end

  describe '#has_files' do
    before { work.has_files = [1, 2, 3] }
    its(:has_files) { is_expected.to eq([1, 2, 3]) }
  end
end
