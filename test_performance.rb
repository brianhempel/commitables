require "benchmark"
require "pry"

REQUEST_PATH = "/tables/a150e50f-f27e-45f9-8ae6-0babac99c6b4?limit=1000"

def server_pid
  `cat tmp/pids/server.pid 2> /dev/null`.to_i
end

def alive?
  system("curl http://localhost:3009/ &> /dev/null")
end

def memory_size_mb
  `ps -o rss= -p#{server_pid}`.to_i / 1024.0
end

if server_pid > 0
  puts "Killing existing server!"
  Process.kill("HUP", server_pid)
  sleep 0.5
end

print "Starting server on port 3009..."
spawn("rails s -p3009 > /dev/null")

at_exit do
  print "Shutting off server..."
  Process.kill("HUP", server_pid)
  Process.wait(server_pid)
  puts "done."
end

sleep(0.1) until alive?

puts "started."
print "Benchmarking #{REQUEST_PATH}..."

request_time = `curl -s -w "Total Time: %{time_total}s\n" -o /dev/null http://localhost:3009/#{REQUEST_PATH}`[/Total Time: ([0-9\.]+)s/, 1].to_f

puts "done."

puts "Request time: %.2fs" % request_time
puts "Memory:       %.1fMB" % memory_size_mb
