# frozen_string_literal: true

namespace :postgres_testing do
  include TestingSupport

  desc 'Run all the Postgres tests'
  task :all, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    Rake::Task['postgres_testing:collections'].invoke(length)
    Rake::Task['postgres_testing:nested_collections'].invoke(length)
    Rake::Task['postgres_testing:files'].invoke(length)
  end

  desc 'Add a lot of works to a collection'
  task :collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))

    collection = Collection.new(
      title: ['Test Collection'],
      description: ['Collection for adding a large number of test works'],
      keywords: ['postgres', 'collections']
    )

    output = adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection)
    end

    $stdout = File.new("tmp/postgres_collections_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      adapter.persister.buffer_into_index do |buffered_adapter|
        (1..length).each do |count|
          work = Work.new(
            title: ["Sample Work #{count}"],
            part_of_collections: output.first.id,
            keywords: ['postgres', 'collections']
          )
          bench.report { buffered_adapter.persister.save(resource: work) }
        end
      end
    end
  end

  desc 'Add N number of collections to a parent collection'
  task :nested_collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))

    collection = Collection.new(
      title: ['Parent Collection'],
      description: ['Collection containing N number of other collections'],
      keywords: ['postgres', 'nested_collections']
    )

    adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection)
    end

    $stdout = File.new("tmp/postgres_nested_collections_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      adapter.persister.buffer_into_index do |buffered_adapter|
        (1..length).each do |count|
          child = Collection.new(
            title: ["Child Collection #{count}"],
            keywords: ['postgres', 'nested_collections']
          )
          result = buffered_adapter.persister.save(resource: child)
          bench.report do
            collection.has_collections << result.id
            buffered_adapter.persister.save(resource: collection)
          end
        end
      end
    end
  end

  desc 'Creating works with files'
  task :files, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::Persistence::Postgres::MetadataAdapter.new,
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))
    storage = Valkyrie::StorageAdapter.find(:disk)

    $stdout = File.new("tmp/postgres_files_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      adapter.persister.buffer_into_index do |buffered_adapter|
        (1..length).each do |count|
          id = SecureRandom.uuid
          randomize_file(id)
          bench.report do
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
  end
end
