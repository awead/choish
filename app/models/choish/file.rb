# frozen_string_literal: true

# Stand-in for a file that Valkyrie can use for uploading. We shouldn't keep this around
# and update Valkyrie::Storage::Disk#upload to be better about {original_filename}.
class Choish::File < File
  # @return [String]
  def original_filename
    File.basename(self)
  end
end
