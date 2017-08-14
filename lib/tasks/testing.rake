# frozen_string_literal: true

namespace :choish do
  desc 'Clean out solr'
  task clear_solr: :environment do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'Clean out all the persisters and indexes'
  task clean: ['db:reset', :clear_solr]

  desc 'Add a lot of works to a collection'
  task :collection_test, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))

    collection = Collection.new(
      title: ['Test Collection'],
      description: ['Collection for adding a large number of test works']
    )
    collection.id = SecureRandom.uuid

    adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection)
    end

    adapter.persister.buffer_into_index do |buffered_adapter|
      (1..length).each do |count|
        work = Work.new
        work.title = ["Sample Work #{count}"]
        work.id = SecureRandom.uuid
        work.collection_id = collection.id
        buffered_adapter.persister.save(resource: work)
      end
    end
  end

  desc 'Add N number of collections to a parent collection'
  task :nested_collection_test, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))

    collection = Collection.new(
      title: ['Parent Collection'],
      description: ['Collection containing N number of other collections']
    )
    collection.id = SecureRandom.uuid

    adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection)
    end

    adapter.persister.buffer_into_index do |buffered_adapter|
      (1..length).each do |count|
        child = Collection.new
        child.title = ["Child Collection #{count}"]
        child.id = SecureRandom.uuid
        buffered_adapter.persister.save(resource: child)
        collection.member_ids << child.id
      end
      buffered_adapter.persister.save(resource: collection)
    end
  end
end
