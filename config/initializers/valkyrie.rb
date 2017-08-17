# frozen_string_literal: true

require 'valkyrie'
Rails.application.config.to_prepare do
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Postgres::MetadataAdapter.new,
    :postgres
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Memory::MetadataAdapter.new,
    :memory
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Disk.new(base_path: Rails.root.join('tmp', 'files')),
    :disk
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Fedora.new(connection: ActiveFedora.fedora.connection),
    :fedora
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Memory.new,
    :memory
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: Blacklight.default_index.connection,
                                                     resource_indexer: Valkyrie::Indexers::AccessControlsIndexer),
    :index_solr
  )
end
