require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'

namespace :browbeat do
  namespace :check do
    desc "Run all cucumber features (ping.feature files first)"
    task :all do
      sh 'bundle exec cucumber features/**/ping.feature features/'
    end

    desc "Run all cucumber features for primo (ping.feature first)"
    task :primo do
      sh 'bundle exec cucumber --require features/ features/primo/ping.feature features/primo/'
    end

    desc "Run all cucumber features for login (ping.feature first)"
    task :login do
      sh 'bundle exec cucumber --require features/ features/login/ping.feature features/login/'
    end

    desc "Run all cucumber features for PDS (ping.feature first)"
    task :pds do
      sh 'bundle exec cucumber --require features/ features/login/pds/ping.feature features/login/pds/'
    end

    desc "Run all cucumber features for e-Shelf (ping.feature first)"
    task :eshelf do
      sh 'bundle exec cucumber --require features/ features/eshelf/ping.feature features/eshelf/'
    end

    desc "Run all cucumber features for GetIt (ping.feature first)"
    task :getit do
      sh 'bundle exec cucumber --require features/ features/getit/ping.feature features/getit/'
    end

    desc "Run all cucumber features for Aleph (ping.feature first)"
    task :aleph do
      sh 'bundle exec cucumber --require features/ features/aleph/ping.feature features/aleph/'
    end
  end
end
