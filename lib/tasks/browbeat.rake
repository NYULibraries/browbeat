require 'dotenv/load'
require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'browbeat'

include Browbeat::Helpers::RakeHelper

namespace :browbeat do
  namespace :ping do
    all_environments.each do |environment|
      desc "Run all cucumber ping features for #{environment}"
      task environment do
        set_environment(environment)
        sh "bundle exec cucumber #{tag_filtering('ping')} features/"
      end
    end
  end

  namespace :check do
    all_environments.each do |environment|
      desc "Run all cucumber ping features for #{environment}"
      task environment do
        set_environment(environment)
        sh "bundle exec cucumber #{tag_filtering('ping')} features/"
      end
    end
  end

  namespace :check do
    all_environments.each do |environment|
      # desc "Run all cucumber features for #{environment} (ping.feature files first)"
      # task environment do
      #   set_environment(environment)
      #   sh "bundle exec cucumber #{tag_filtering} features/**/ping.feature features/"
      # end

      namespace environment do
        FEATURE_GROUPS.each do |directory, application_name|
          desc "Run cucumber features for #{environment} #{application_name} (ping.feature first)"
          task directory do
            set_environment(environment)
            sh "bundle exec cucumber #{tag_filtering} --require features/ features/#{directory}/ping.feature features/#{directory}/"
          end
        end

        desc "Run cucumber features for #{environment} PDS (ping.feature first)"
        task :pds do
          set_environment(environment)
          sh "bundle exec cucumber #{tag_filtering} --require features/ features/login/pds/ping.feature features/login/pds/"
        end
      end
    end
  end

  namespace :recheck do
    all_environments.each do |environment|
      desc "For #{environment} applications failing in Status Page, run all #{environment} cucumber features (ping.feature files first)"
      task environment do
        set_environment(environment)
        if failing_applications.any?
          sh "bundle exec cucumber #{tag_filtering} --require features/ #{failing_application_features} RECHECK=true"
        else
          puts "All applications operational in StatusPage #{all_environments.join(" and ")}"
        end
      end
    end
  end
end
