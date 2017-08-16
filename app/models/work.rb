# frozen_string_literal: true

class Work < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title, Valkyrie::Types::Set
  attribute :description, Valkyrie::Types::Set
  attribute :keywords, Valkyrie::Types::Array
  attribute :part_of_collections, Valkyrie::Types::Array
  attribute :has_files, Valkyrie::Types::Array
end
