class RResource < ActiveRecord::Base
  #belongs_to :location,:class_name=>'RLocation',:foreign_key=>'location_id'  
  belongs_to :domain,:class_name=>'RDomain',:foreign_key=>'domain_id'
  def replicas
    
  end
  
  def before_save
    self.created_at=Time.now
  end
  
  def self.create_or_update(obj)
    cur_obj=self.find :first,:conditions=>{:name=>obj.name}
    if cur_obj
      #cur_obj.update_attributes obj.attributes
      cur_obj.name=obj.name
      cur_obj.domain_id=obj.domain_id
      cur_obj.address=obj.address
      cur_obj.save   
    else
      obj.save
    end
  end    
  
  def self.sync
    u=RUser.find :first
    results=u.query [:resource_name,:resource_address_netprefix],{}
    results.each do |r|
      #中研院說跳過這些resource
      next if ["01_hunter01_IISAS","01_firefox_NTU"].index(r.resource_name)
      domain=RDomain.find :first,:conditions=>{:name=>r.resource_name.split('_')[2]}
      if domain
        resource=RResource.new :name=>r.resource_name,:domain_id=>domain.id,:address=>r.resource_address_netprefix.split(":")[0]
        RResource.create_or_update resource
      end  
    end
  end
  
  def can_connect?(save=true, u=nil)
    u=RUser.find :first if !u
    #result=RZone.connect address,5544,u.username,u.password,u.domain.name,u.zone.name
    begin
      account=SRBAccount.new address,5544,u.username,u.password,"",u.domain.name,"",u.zone.name
      filesystem=SRBFileSystem.new(account)
      result=filesystem.isConnected
      filesystem.close
      rescue=>e
      result=false
    end
    if save
      if !result
        self.downtime=self.downtime+1
        self.online=false
        self.save
      else
        self.online=true
        self.save
      end
    end
    result
  end
  
end
