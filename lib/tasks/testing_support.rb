# frozen_string_literal: true

module TestingSupport
  def randomize_file(id)
    FileUtils.rm_f('tmp/small_random.bin')
    FileUtils.cp('spec/fixtures/small_random.bin', 'tmp')
    File.open('tmp/small_random.bin', 'a') do |file|
      file.truncate((file.size - 36))
      file.syswrite(id)
    end
  end

  # @return [RDF::URI]
  def id_to_uri(id)
    RDF::URI(ActiveFedora::Base.id_to_uri(ActiveFedora::Noid.treeify(id.to_s)))
  end
end
