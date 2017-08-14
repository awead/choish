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
end
