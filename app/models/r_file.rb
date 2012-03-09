class RFile < ActiveRecord::Base
  belongs_to :user,:class_name=>'RUser',:foreign_key=>'user_id'  
  belongs_to :policy
  has_many :logs,:class_name=>'ReplicaLog',:foreign_key=>'file_id'
  
  attr_reader :file_name,:directory_name,:size,:owner,:owner_domain,:user_name,:user_domain,:zone_name
  RFILE_SELECT=[:file_name,:directory_name,:size,:owner,:owner_domain,:user_name,:user_domain,:zone_name]  
  
  def self.create_or_update(obj)
    cur_obj=self.find :first,:conditions=>{:name=>obj.name,:path=>obj.path}
    if cur_obj
      cur_obj.update_attributes obj.attributes
    else
      obj.save
    end
  end    
  
  def exists?
    if !self.user #要呼叫exists?之前，一定要先file.user=file.owner，不然會使用預設帳號登入導致無權限存取檔案
      self.user=RUser.find(1)
    end
    return true if self.file.isFile
    false
  end
  
  def filesystem
    self.user.filesystem
  end
    
  #取得邏輯SRBFile
  def file(num=nil)
    self.user.connect
    if num
      return SRBFile.new(self.user.filesystem,self.path+'/'+self.name+"&COPY=#{num}")
    else
      return SRBFile.new(self.user.filesystem,self.path+'/'+self.name)
    end
  end
  
  #開啟輸出入串流
  def open
    SRBRandomAccessFile.new file,"rw"
  end
  
  def read_attr
    if !self.user #要呼叫exists?之前，一定要先file.user=file.owner，不然會使用預設帳號登入導致無權限存取檔案
      self.user=RUser.find(1)
    end    
    self.user.query(RFILE_SELECT,{:directory_name=>"= "+self.path,:file_name=>"= "+self.name}).each do |result|
      RFILE_SELECT.each do |s|
        instance_variable_set "@#{s.to_s}",result.send(s)
      end
    end
  end
  
  #取得實體Replica
  def replicas
    self.user.query(RFILE_SELECT+[:file_replication_enum,:path_name,:resource_address_netprefix,:resource_name],{:directory_name=>"= "+self.path,:file_name=>"= "+self.name}).collect do |result|
      r=Replica.new
      r.physical_path=result.path_name
      r.number=result.file_replication_enum
      r.resource_name=result.resource_name
      r.resource_address=result.resource_address_netprefix.split(":")[0]
      r.resource=RResource.find :first,:conditions=>{:name=>result.resource_name}
      r
    end
  end
    
  def replicate(resource)
    old_replica=self.replicas
    case resource
    when String
      log=ReplicaLog.new
      log.file_id=self.id
      log.action="Replicate"
      log.resource=resource
      begin
        if RResource.find(:first, :conditions=>{:name=>resource}).online
          self.file.replicate resource
          log.success=true
        else
          log.success=false
        end
        rescue=>e
        logger.warn "#{e} #{e.backtrace}"
        log.success=false
      end
      log.save
    when Array
      resource.each do |r|
        log=ReplicaLog.new
        log.file_id=self.id
        log.action="Replicate"
        log.resource=r
        begin
          if RResource.find(:first, :conditions=>{:name=>r}).online
            self.file.replicate r
            log.success=true
          else
            log.success=false
          end
          rescue=>e
          logger.warn "#{e} #{e.backtrace}"
          log.success=false
        end
        log.save
      end  
    end
    new_replica=self.replicas
    return true if new_replica.size > old_replica.size
    false
  end
  
  #replica method
  def init_replica_method
    #    self.include self.policy.replica_method.constantize
    #self.class.class_eval "include #{self.policy.replica_method.class.to_s}::ModelMethods"
    self.extend self.policy.replica_method.class::ModelMethods
    self.init
  end
  
  
  
  
end
