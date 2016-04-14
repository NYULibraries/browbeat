namespace :docker do
  # runs setup commands to enable docker in terminal window, starting daemon if necessary
  desc "Enable docker daemon and prints command needed to modify PATH for command-line tools"
  task :enable do
    puts "Starting docker daemon..."
    puts `docker-machine start default` # starts docker daemon
    puts `docker-machine env`
    puts "You may need to run the following to modify your PATH to access docker command-line tools:\n   eval \"$(docker-machine env default)\""
  end

  # builds docker compose after preconfiguring (for database)
  desc "Build docker compose after preconfiguring"
  task :build do
    puts `docker-compose build`
  end

  # runs docker compose after building
  desc "Run docker compose after building (and preconfiguring)"
  task :up => [:build] do
    puts `docker-compose up`
  end
end
