require File.join(File.dirname(__FILE__), '../config/environment')

if RUBY_PLATFORM =~/mswin32/
  file=File.new "#{RAILS_ROOT}/log/replicator.pid","w"
  file.puts Process.pid.to_s
  file.close
end
trap "INT" do
  puts "removing pid file ..."
  file=Pathname.new "#{RAILS_ROOT}/log/replicator.pid"
  file.delete if file.exist?
end



while(true)
  begin
    RFile.find(:all,:order=>"path asc").each do |e|
      puts "-----------------------------------------------------"
      puts "File: #{e.path}/#{e.name}\nLevel: #{e.policy.name} \n"
      puts "Candidate:\n"
      e.init_replica_method
      candidate=e.get_candidate
      delete=e.get_delete
      p candidate
      p delete
      e.replicate candidate if candidate.size>0
      e.delete_replica
    end
  rescue=>e
    p "#{e} #{e.backtrace}"
  end

  sleep 1

end