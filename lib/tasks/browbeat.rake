require 'figs'; Figs.load()
require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'browbeat'

include Browbeat::Helpers::RakeHelper

namespace :browbeat do
  namespace :check do
    desc "Run all cucumber features (ping.feature files first)"
    task :all do
      sh "bundle exec cucumber #{tag_filtering} features/**/ping.feature features/"
    end

    FEATURE_GROUPS.each do |directory, application_name|
      desc "Run cucumber features for #{application_name} (ping.feature first)"
      task directory do
        sh "bundle exec cucumber #{tag_filtering} --require features/ features/#{directory}/ping.feature features/#{directory}/"
      end
    end

    desc "Run cucumber features for PDS (ping.feature first)"
    task :pds do
      sh "bundle exec cucumber #{tag_filtering} --require features/ features/login/pds/ping.feature features/login/pds/"
    end
  end

  namespace :recheck do
    desc "For applications failing in Status Page, run all cucumber features (ping.feature files first)"
    task :failures do
      if failing_applications.any?
        sh "bundle exec cucumber #{tag_filtering} --require features/ #{failing_application_features} RECHECK=true"
      else
        puts "All applications operational in StatusPage #{all_environments.join(" and ")}"
      end
    end
  end
end
