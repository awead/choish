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

  describe '#collection_id' do
    before { work.collection_id = 1 }
    its(:collection_id) { is_expected.to be_kind_of(Valkyrie::ID) }
  end

  describe '#file_ids' do
    before { work.file_ids = [1, 2, 3] }
    its(:file_ids) { is_expected.to eq([1, 2, 3]) }
  end
end
