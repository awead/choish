# frozen_string_literal: true

namespace :fedora_testing do
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
end
