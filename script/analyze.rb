require File.expand_path('../../config/environment', __FILE__)

results = {}

CollectionsProfile.where(run_id: CollectionsProfile.maximum(:run_id)).each do |last_run|
  first_run = CollectionsProfile.where(run_id: 1  , name: last_run.name).first
  if first_run
    diff = last_run.total - first_run.total
    results[last_run.name] = diff if diff > 1
  end
end

sorted = results.sort_by {|_key, value| value}.to_h
sorted.each { |k,v| puts "#{k}: #{v}" }
