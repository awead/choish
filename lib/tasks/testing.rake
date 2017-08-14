# frozen_string_literal: true

namespace :choish do
  desc 'Add a lot of works to a collection'
  task :collection_test, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = Valkyrie::Persistence::Postgres::MetadataAdapter.new
    collection = Collection.new(
      title: ['Test Collection'],
      description: ['Collection for adding a large number of test works']
    )
    collection.id = SecureRandom.uuid
    adapter.persister.save(resource: collection)

    (1..length).each do |count|
      work = Work.new
      work.title = ["Sample Work #{count}"]
      work.id = SecureRandom.uuid
      work.collection_id = collection.id
      adapter.persister.save(resource: work)
    end
  end

  desc 'Add N number of collections to a parent collection'
  task :nested_collection_test, [:length] => [:environment] do |_t, args|
    length = args.fetch(:length, 10).to_i
    adapter = Valkyrie::Persistence::Postgres::MetadataAdapter.new
    collection = Collection.new(
      title: ['Parent Collection'],
      description: ['Collection containing N number of other collections']
    )
    collection.id = SecureRandom.uuid
    adapter.persister.save(resource: collection)

    (1..length).each do |count|
      child = Collection.new
      child.title = ["Child Collection #{count}"]
      child.id = SecureRandom.uuid
      adapter.persister.save(resource: child)
      collection.member_ids << child.id
    end
    adapter.persister.save(resource: collection)
  end
end
