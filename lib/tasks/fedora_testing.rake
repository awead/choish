# frozen_string_literal: true

namespace :fedora_testing do
  desc 'Run all the Fedora tests'
  task all: [:collections, :nested_collections, :files]

  desc 'Add a lot of works to a collection in Fedora'
  task :collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = Valkyrie::MetadataAdapter.find(:fedora)

    collection_resource = Collection.new(
      title: ['Test Collection'],
      description: ['Fedora test for a collection containing a large number of works'],
      keywords: ['fedora', 'collections']
    )

    # @comment Although we persist {collection_resource} its object doesn't get
    # modified by the results of the process. The output from {#save} is captured
    # to a new object, {collection}, which actually contains the information resulting
    # from the persist process, such as the Fedora id that was minted.
    collection = adapter.persister.save(resource: collection_resource)

    (1..length).each do |count|
      work = Work.new(title: ["Sample Work #{count}"], keywords: ['fedora', 'collections'])
      work.part_of_collections = [collection.id.to_uri]
      adapter.persister.save(resource: work)
    end
  end

  desc 'Add N number of collections to a parent collection in Fedora'
  task :nested_collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = Valkyrie::MetadataAdapter.find(:fedora)

    collection_resource = Collection.new(
      title: ['Test Collection'],
      description: ['Fedora test for a collection containing child collections'],
      keywords: ['fedora', 'nested_collections']
    )

    children = []

    (1..length).each do |count|
      child = Collection.new(title: ["Child Collection #{count}"], keywords: ['fedora', 'nested_collections'])
      result = adapter.persister.save(resource: child)
      children << result
    end
    collection_resource.has_collections = children.map(&:id)
    collection = adapter.persister.save(resource: collection_resource)
    puts "Collection uri = #{collection.id.to_uri}"
  end

  desc 'Creating works with files in Fedora'
  task :files, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))
    storage = Valkyrie::StorageAdapter.find(:fedora)

    adapter.persister.buffer_into_index do |buffered_adapter|
      (1..length).each do |count|
        id = SecureRandom.uuid
        randomize_file(id)
        work = Work.new(
          id: id,
          title: ["Sample Work with a file in Fedora #{count}"],
          keywords: ['fedora', 'files']
        )
        file = storage.upload(
          file: Choish::File.open('tmp/small_random.bin', 'r'),
          resource: work
        )
        work.has_files = [file.id]
        buffered_adapter.persister.save(resource: work)
      end
    end
  end
end
