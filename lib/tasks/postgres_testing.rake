# frozen_string_literal: true

namespace :postgres_testing do
  include TestingSupport

  desc 'Run all the Postgres tests'
  task all: [:collections, :nested_collections, :files]

  desc 'Add a lot of works to a collection'
  task :collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))

    collection = Collection.new(
      id: SecureRandom.uuid,
      title: ['Test Collection'],
      description: ['Collection for adding a large number of test works'],
      keywords: ['postgres', 'collections']
    )

    adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection)
    end

    adapter.persister.buffer_into_index do |buffered_adapter|
      (1..length).each do |count|
        work = Work.new(
          title: ["Sample Work #{count}"],
          id: SecureRandom.uuid,
          part_of_collections: collection.id,
          keywords: ['postgres', 'collections']
        )
        buffered_adapter.persister.save(resource: work)
      end
    end
  end

  desc 'Add N number of collections to a parent collection'
  task :nested_collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))

    collection = Collection.new(
      id: SecureRandom.uuid,
      title: ['Parent Collection'],
      description: ['Collection containing N number of other collections'],
      keywords: ['postgres', 'nested_collections']
    )

    adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection)
    end

    children = []

    adapter.persister.buffer_into_index do |buffered_adapter|
      (1..length).each do |count|
        child = Collection.new(
          title: ["Child Collection #{count}"],
          id: SecureRandom.uuid,
          keywords: ['postgres', 'nested_collections']
        )
        result = buffered_adapter.persister.save(resource: child)
        children << result
      end
      collection.has_collections = children.map(&:id)
      buffered_adapter.persister.save(resource: collection)
    end
  end

  desc 'Creating works with files'
  task :files, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))
    storage = Valkyrie::StorageAdapter.find(:disk)

    adapter.persister.buffer_into_index do |buffered_adapter|
      (1..length).each do |count|
        id = SecureRandom.uuid
        randomize_file(id)
        work = Work.new
        work.title = ["Sample Work with file #{count}"]
        work.id = id
        file = storage.upload(
          file: Choish::File.open('tmp/small_random.bin', 'r'),
          resource: work
        )
        work.has_files = [file.id]
        work.keywords = ['postgres', 'files']
        buffered_adapter.persister.save(resource: work)
      end
    end
  end
end
