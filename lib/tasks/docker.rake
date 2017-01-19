require 'browbeat'

include Browbeat::Helpers::EnvironmentHelper

namespace :docker do
  # runs setup commands to enable docker in terminal window, starting daemon if necessary
  desc "Enable docker daemon and prints command needed to modify PATH for command-line tools"
  task :enable do
    puts "Starting docker daemon..."
    sh 'docker-machine start default' # starts docker daemon
    sh 'docker-machine env'
    puts "You may need to run the following to modify your PATH to access docker command-line tools:\n   eval \"$(docker-machine env default)\""
  end

  # builds docker compose after preconfiguring (for database)
  desc "Build docker compose after preconfiguring"
  task :build do
    sh 'docker-compose build'
    # ensure docker user owns gembox (volume for gems)
    sh 'docker-compose run -u root web chown -R wsops /gembox'
  end

  # runs docker compose after building
  desc "Run docker compose after building (and preconfiguring)"
  task :up => [:build] do
    sh 'docker-compose up'
  end

  namespace :browbeat do
    namespace :check do
      all_environments.each do |environment|
        namespace environment do
          desc "Run all #{environment} cucumber tests in docker containers"
          task :all => ["docker:up"] do
            sh "docker-compose run web bundle exec rake browbeat:check:#{environment}:all"
          end

          FEATURE_GROUPS.each do |directory, application_name|
            desc "Run cucumber features for #{environment} #{application_name} in docker containers"
            task directory => ["docker:up"] do
              sh "docker-compose run web bundle exec rake browbeat:check:#{environment}:#{directory}"
            end
          end

          desc "Run cucumber tests for #{environment} PDS in docker containers"
          task :pds => ["docker:up"] do
            sh "docker-compose run web bundle exec rake browbeat:check:#{environment}:pds"
          end
        end
      end
    end
  end
end
