class RZone < ActiveRecord::Base
  #assoc
  has_many :domains,:class_name=>'RDomain',:foreign_key=>'zone_id'
  
  include LibReplicator::ModelMethods

  def self.connect(host,port,username,password,domain,zone)
    #return if connected? && !force
    begin
    account=SRBAccount.new host,port,username,password,"",domain,"",zone
    filesystem=SRBFileSystem.new(account)
    filesystem.isConnected
    rescue
      return false
    end  
  end  
  
  def self.create_or_update(obj)
    cur_obj=self.find :first,:conditions=>{:name=>obj.name}
    if cur_obj
      cur_obj.update_attributes obj.attributes
    else
      obj.save
    end
  end    
  
  def self.sync
    u=RUser.find :first
    results=u.query [:zone_name,:zone_netprefix],{}
    results.each do |r|
      zone=RZone.new :name=>r.zone_name,:port=>5544,:host=>r.zone_netprefix.split(":")[0]
      RZone.create_or_update zone
    end
  end

end
