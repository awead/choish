# frozen_string_literal: true

require 'active_fedora/cleaner'

namespace :testing_support do
  desc 'Clean out solr'
  task clear_solr: :environment do
    Blacklight.default_index.connection.delete_by_query('*:*')
    Blacklight.default_index.connection.commit
  end

  desc 'Clean out files'
  task clear_files: :environment do
    FileUtils.rm_rf('tmp/files')
  end

  desc 'Clean out Fedora'
  task clear_fedora: :environment do
    ActiveFedora::Cleaner.cleanout_fedora
    FileUtils.rm_f('log/fedora-dev.log')
  end

  desc 'Truncate tables'
  task truncate: :environment do
    conn = ActiveRecord::Base.connection
    (conn.tables - ['schema_migrations']).each { |t| conn.truncate(t) }
  end

  desc 'Clean out all the persisters and indexes'
  task clean: [:truncate, :clear_solr, :clear_files, :clear_fedora]
end
