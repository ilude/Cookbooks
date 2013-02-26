Bluepill.application("fnord", :log_file => "/tmp/bluepill.log") do |app|
  app.process("process_name") do |process|
    process.start_command = "/usr/local/bin/ruby /root/server.rb > /tmp/fnordmetric.log 2>&1"
    process.pid_file = "/tmp/fnordmetric.pid"
    process.daemonize = true
    process.start_grace_time = 3.seconds
    process.stop_grace_time = 40.seconds
    process.restart_grace_time = 45.seconds


    process.stop_signals = [:quit, 30.seconds, :term, 5.seconds, :kill]

    process.checks :cpu_usage, :every => 5.seconds, :below => 20, :times => 3
    process.checks :mem_usage, :every => 5.seconds, :below => 512.megabytes, :times => 3
  end
end
