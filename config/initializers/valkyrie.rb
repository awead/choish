# frozen_string_literal: true

require 'valkyrie'
Rails.application.config.to_prepare do
  # Metadata Adapters

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Postgres::MetadataAdapter.new,
    :postgres
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Memory::MetadataAdapter.new,
    :memory
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: Blacklight.default_index.connection,
                                                     resource_indexer: Valkyrie::Indexers::AccessControlsIndexer),
    :index_solr
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::ActiveFedora::MetadataAdapter.new,
    :active_fedora
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(
      connection: ::Ldp::Client.new(ActiveFedora.config.credentials[:url]),
      base_path: ActiveFedora.config.credentials[:base_path].gsub(/\//, '')
    ),
    :fedora
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::IndexingAdapter.new(
      metadata_adapter: Valkyrie.config.metadata_adapter,
      index_adapter: Valkyrie::MetadataAdapter.find(:index_solr)
    ),
    :indexing_persister
  )

  # Storage Adapters

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
end
