# frozen_string_literal: true

namespace :fedora_testing do
  include TestingSupport

  desc 'Run all the Fedora tests'
  task :all, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    Rake::Task['fedora_testing:collections'].invoke(length)
    Rake::Task['fedora_testing:nested_collections'].invoke(length)
    Rake::Task['fedora_testing:files'].invoke(length)
  end

  desc 'Add a lot of works to a collection in Fedora'
  task :collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::MetadataAdapter.find(:fedora),
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))
    collection = Collection.new(
      title: ['Test Collection'],
      description: ['Fedora test for a collection containing a large number of works'],
      keywords: ['fedora', 'collections']
    )

    output = adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection)
    end

    $stdout = File.new("tmp/fedora_collections_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      adapter.persister.buffer_into_index do |buffered_adapter|
        (1..length).each do |count|
          work = Work.new(title: ["Sample Work #{count}"], keywords: ['fedora', 'collections'])
          work.part_of_collections = [id_to_uri(output.first.id)]
          bench.report { buffered_adapter.persister.save(resource: work) }
        end
      end
    end
  end

  desc 'Add N number of collections to a parent collection in Fedora'
  task :nested_collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::MetadataAdapter.find(:fedora),
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))

    collection_resource = Collection.new(
      title: ['Test Collection'],
      description: ['Fedora test for a collection containing child collections'],
      keywords: ['fedora', 'nested_collections']
    )

    adapter.persister.buffer_into_index do |buffered_adapter|
      buffered_adapter.persister.save(resource: collection_resource)
    end

    $stdout = File.new("tmp/fedora_nested_collections_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      adapter.persister.buffer_into_index do |buffered_adapter|
        (1..length).each do |count|
          child = Collection.new(title: ["Child Collection #{count}"], keywords: ['fedora', 'nested_collections'])
          result = adapter.persister.save(resource: child)
          bench.report do
            collection_resource.has_collections << id_to_uri(result.id)
            buffered_adapter.persister.save(resource: collection_resource)
          end
        end
      end
    end
  end

  desc 'Creating works with files in Fedora'
  task :files, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = IndexingAdapter.new(metadata_adapter: Valkyrie::MetadataAdapter.find(:fedora),
                                  index_adapter: Valkyrie::MetadataAdapter.find(:index_solr))
    storage = Valkyrie::StorageAdapter.find(:fedora)

    $stdout = File.new("tmp/fedora_files_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      adapter.persister.buffer_into_index do |buffered_adapter|
        (1..length).each do |count|
          id = SecureRandom.uuid
          randomize_file(id)
          bench.report do
            file_set = Work.new(title: ["File set for file #{count}"])
            file_set = buffered_adapter.persister.save(resource: file_set)

            file = storage.upload(
              file: Choish::File.open('tmp/small_random.bin', 'r'),
              resource: file_set
            )

            work = Work.new(
              id: id,
              title: ["Sample Work with a file in Fedora #{count}"],
              keywords: ['fedora', 'files'],
              has_files: [RDF::URI(file.id.to_s.gsub(/fedora/, 'http'))]
            )
            buffered_adapter.persister.save(resource: work)
          end
        end
      end
    end
  end
end
