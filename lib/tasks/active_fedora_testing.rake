# frozen_string_literal: true

namespace :active_fedora_testing do
  desc 'Run all the Fedora tests'
  task :all, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    Rake::Task['active_fedora_testing:collections'].invoke(length)
    Rake::Task['active_fedora_testing:nested_collections'].invoke(length)
    Rake::Task['active_fedora_testing:files'].invoke(length)
  end

  desc 'Add a lot of works to a collection in Fedora'
  task :collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = Valkyrie::MetadataAdapter.find(:active_fedora)

    collection_resource = Collection.new(
      title: ['Test Collection'],
      description: ['Fedora test for a collection containing a large number of works'],
      keywords: ['active_fedora', 'collections']
    )

    # @comment Although we persist {collection_resource} its object doesn't get
    # modified by the results of the process. The output from {#save} is captured
    # to a new object, {collection}, which actually contains the information resulting
    # from the persist process, such as the Fedora id that was minted.
    collection = adapter.persister.save(resource: collection_resource)

    $stdout = File.new("tmp/active_fedora_collections_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      (1..length).each do |count|
        work = Work.new(title: ["Sample Work #{count}"], keywords: ['active_fedora', 'collections'])
        work.part_of_collections = [collection.id.to_uri]
        bench.report { adapter.persister.save(resource: work) }
      end
    end

    FileUtils.cp('log/fedora-dev.log', "log/active_fedora_collections_#{length}.log")
  end

  desc 'Add N number of collections to a parent collection in Fedora'
  task :nested_collections, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = Valkyrie::MetadataAdapter.find(:active_fedora)

    collection_resource = Collection.new(
      title: ['Test Collection'],
      description: ['Fedora test for a collection containing child collections'],
      keywords: ['active_fedora', 'nested_collections']
    )

    $stdout = File.new("tmp/active_fedora_nested_collections_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      (1..length).each do |count|
        child = Collection.new(title: ["Child Collection #{count}"], keywords: ['active_fedora', 'nested_collections'])
        result = adapter.persister.save(resource: child)
        bench.report do
          collection_resource.has_collections << result.id
          adapter.persister.save(resource: collection_resource)
        end
      end
    end
  end

  desc 'Creating works with files in Fedora'
  task :files, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = Valkyrie::MetadataAdapter.find(:active_fedora)
    storage = Valkyrie::StorageAdapter.find(:fedora)

    $stdout = File.new("tmp/active_fedora_files_#{length}.csv", 'w')
    $stdout.sync = true

    Benchmark.benchmark("User,System,Total,Real\n", 0, "%u,%y,%t,%r\n") do |bench|
      (1..length).each do |count|
        id = SecureRandom.uuid
        randomize_file(id)
        bench.report do
          work = Work.new(
            id: id,
            title: ["Sample Work with a file in Fedora #{count}"],
            keywords: ['active_fedora', 'files']
          )
          file = storage.upload(
            file: Choish::File.open('tmp/small_random.bin', 'r'),
            resource: work
          )
          work.has_files = [file.id]
          adapter.persister.save(resource: work)
        end
      end
    end
  end
end
