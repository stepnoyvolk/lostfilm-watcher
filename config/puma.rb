threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

port        ENV.fetch("PORT") { 80808 }
environment ENV.fetch("RAILS_ENV") { "production" }
bind "unix://srv/lostfilm-watcher/sockets/puma.sock"

plugin :tmp_restart

