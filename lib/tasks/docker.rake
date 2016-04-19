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
  end

  # runs docker compose after building
  desc "Run docker compose after building (and preconfiguring)"
  task :up => [:build] do
    sh 'docker-compose up'
  end

  namespace :browbeat do
    namespace :check do
      desc "Run all cucumber tests in docker containers"
      task :all => ["docker:up"] do
        sh 'docker-compose run web rake browbeat:check:all'
      end

      desc "Run all cucumber tests for primo in docker containers"
      task :primo => ["docker:up"] do
        sh 'docker-compose run web rake browbeat:check:primo'
      end

      desc "Run all cucumber tests for login in docker containers"
      task :login => ["docker:up"] do
        sh 'docker-compose run web rake browbeat:check:login'
      end
    end
  end
end
