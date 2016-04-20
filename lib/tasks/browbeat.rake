require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'

namespace :browbeat do
  namespace :check do
    desc "Run all cucumber features (ping.feature files first)"
    task :all do
      sh 'cucumber features/**/ping.feature features/'
    end

    desc "Run all cucumber features for primo (ping.feature first)"
    task :primo do
      sh 'cucumber features/primo/ping.feature features/primo/'
    end

    desc "Run all cucumber features for login (ping.feature first)"
    task :login do
      sh 'cucumber features/login/ping.feature features/login/'
    end
  end
end
