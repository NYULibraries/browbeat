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
  special_collections: "Special Collections",
  privileges: "Privileges",
  website: "Library.nyu.edu website",
  marli: "MaRLi",
  illiad: "ILLiad",
  ezborrow: "EZBorrow",
  ezproxy: "EZProxy",
}

def tag_filtering
  tags = ""
  tags += " --tags @#{ENV['BROWBEAT_ENV']}" if ENV['BROWBEAT_ENV']
  tags += " --tags ~@no_sauce" if ENV['DRIVER'] == 'sauce'
  tags
end

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
      sh 'bundle exec cucumber #{tag_filtering} --require features/ features/login/pds/ping.feature features/login/pds/'
    end
  end
end
