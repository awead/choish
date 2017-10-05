require File.expand_path('../../config/environment', __FILE__)

ActiveRecord::Base.connection.execute("TRUNCATE public.collections_profiles")

Dir.glob("#{ARGV[0]}/*.txt") do |file|
  run_id = file.split(/_/).last.to_i
  count = 1
  File.open(file, 'r').each do |line|
    # skip first 7 lines, stop at the first blank line
    if count > 7
      values = line.chomp.split(/ +/).reject!(&:empty?)

      unless values.nil? || values[6].nil?
        if values[1].to_f > 0.01
          CollectionsProfile.create(
            name: values[6],
            run_id: run_id,
            total: values[1].to_f,
            wait: values[3].to_f,
            child: values[4].to_f,
            calls: values[5].to_i,
            percent_self: values[0].to_f,
            self: values[2].to_f
          )
        end
      end

      break if line == "\n"
    end
    count = count + 1
  end
end
