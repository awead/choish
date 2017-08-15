# frozen_string_literal: true

namespace :choish do
  desc 'Clean out solr'
  task clear_solr: :environment do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'Clean out files'
  task clear_files: :environment do
    FileUtils.rm_rf('tmp/files')
  end

  desc 'Clean out all the persisters and indexes'
  task clean: ['db:reset', :clear_solr, :clear_files]

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

  desc 'Creating works with fMetadataAdapteriles'
  task :files_test, [:length] => [:environment] do |_t, args|
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
        work.file_ids = [file.id]
        buffered_adapter.persister.save(resource: work)
      end
    end
  end

  def randomize_file(id)
    FileUtils.rm_f('tmp/small_random.bin')
    FileUtils.cp('spec/fixtures/small_random.bin', 'tmp')
    File.open('tmp/small_random.bin', 'a') do |file|
      file.truncate((file.size - 36))
      file.syswrite(id)
    end
  end
end
