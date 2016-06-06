require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'

FEATURE_GROUPS = {
  primo: "Primo",
  login: "Login",
  eshelf: "e-Shelf",
  getit: "GetIt",
  aleph: "Aleph",
  arch: "Arch",
}

namespace :browbeat do
  namespace :check do
    desc "Run all cucumber features (ping.feature files first)"
    task :all do
      sh 'bundle exec cucumber features/**/ping.feature features/'
    end

    FEATURE_GROUPS.each do |directory, application_name|
      desc "Run all cucumber features for #{application_name} (ping.feature first)"
      task directory do
        sh "bundle exec cucumber --require features/ features/#{directory}/ping.feature features/#{directory}/"
      end
    end

    desc "Run all cucumber features for PDS (ping.feature first)"
    task :pds do
      sh 'bundle exec cucumber --require features/ features/login/pds/ping.feature features/login/pds/'
    end
  end
end
