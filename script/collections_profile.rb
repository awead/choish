require 'ruby-prof'
require File.expand_path('../../config/environment', __FILE__)

length = (ARGV[0] || 10).to_i

adapter = Valkyrie::MetadataAdapter.find(:active_fedora)

collection_resource = Collection.new(
  title: ['Test Collection'],
  description: ['Fedora test for a collection containing a large number of works'],
  keywords: ['active_fedora', 'collections']
)

collection = adapter.persister.save(resource: collection_resource)

(1..length).each do |count|
  work = Work.new(title: ["Sample Work #{count}"], keywords: ['active_fedora', 'collections'])
  work.part_of_collections = [collection.id.to_uri]

  if (count == 1) || (count % 1000 == 0)
    result = RubyProf.profile { adapter.persister.save(resource: work) }
    RubyProf::FlatPrinter.new(result).print(File.new("tmp/active_fedora_collections_profile_#{count}.txt", 'w'))
  else
    adapter.persister.save(resource: work)
  end
end
