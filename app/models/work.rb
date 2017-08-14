# frozen_string_literal: true

class Work < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title, Valkyrie::Types::Set
  attribute :description, Valkyrie::Types::Set
  attribute :member_ids, Valkyrie::Types::Array
end
