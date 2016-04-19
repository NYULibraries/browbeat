require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'

namespace :browbeat do
  namespace :check do
    Cucumber::Rake::Task.new :all

    Cucumber::Rake::Task.new :primo do |t|
      t.cucumber_opts = "features/primo/"
    end

    Cucumber::Rake::Task.new :login do |t|
      t.cucumber_opts = "features/login/"
    end
  end
end
