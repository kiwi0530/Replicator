class MonitorController < ApplicationController
  def downtime
    @zones=RZone.find :all
    
  end
  
  def log
    file=Pathname.new "#{RAILS_ROOT}/log/replicator.pid"
    if file.exist?
      @pid=file.read
    end
    @logs=ReplicaLog.find :all,:order=>'created_at desc'
    
  end
  
  def a_log
    @logs=ReplicaLog.find :all,:order=>'created_at desc'
    render :layout=>false
  end
  
end
