class ReplicatorController < ApplicationController
  wsdl_service_name "Replicator"
  wsdl_namespace 'unigrid.chu.replicator.api'
  web_service_scaffold :invoke  
  
  def set_policy(srbfilepath,policy,owner)  
    path=Pathname.new srbfilepath
    file=RFile.find_by_name_and_path path.basename.to_s,path.dirname.to_s
    policy=Policy.find_by_name policy
    return false if !policy
    if file
      file.policy=policy
      file.save
          #active replication, dn't use passive
          logger.info "start to replicate..."          
          e=RFile.find(file.id,:order=>"path asc")
          logger.info "File: #{e.path}/#{e.name}\nLevel: #{e.policy.name} \n"
          e.init_replica_method
          candidate=e.get_candidate
          delete=e.get_delete
          logger.info "Candidate:#{candidate.inspect}\n"
          logger.info "Delete:#{delete.inspect}\n"
          e.replicate candidate if candidate.size>0
          e.delete_replica    
      return true
    else
      file=RFile.new :name=>path.basename.to_s,:path=>path.dirname.to_s
      user=RUser.find_by_username owner      
      if user      
        file.user=user
        file.policy_id=policy.id        
        if file.exists?
          RFile.create_or_update file

          #active replication, dn't use passive
          logger.info "start to replicate..."          
          e=RFile.find(file.id,:order=>"path asc")
          logger.info "File: #{e.path}/#{e.name}\nLevel: #{e.policy.name} \n"
          e.init_replica_method
          candidate=e.get_candidate
          delete=e.get_delete
          logger.info "Candidate:#{candidate.inspect}\n"
          logger.info "Delete:#{delete.inspect}\n"
          e.replicate candidate if candidate.size>0
          e.delete_replica    
          return true          
        else
          return false
        end      
      else
        return false
      end      
    end
    false
  end
  
  def set_custom_policy(srbfilepath,resources,owner)
    path=Pathname.new srbfilepath
    file=RFile.find_by_name_and_path path.basename.to_s,path.dirname.to_s
    if !file 
      file=RFile.new :name=>path.basename.to_s,:path=>path.dirname.to_s
      #check file owner
      user=RUser.find_by_username owner
      if user
        file.user=user    
        if file.exists?
          RFile.create_or_update file          
        else
          return "Error: no such file"
        end      
      else
        return "Error: file owner is not a unigrid user"
      end      
    end
    #custom policy一定是重新建立
    file.policy=CustomPolicy.create :name=>"#{srbfilepath}_custom",:replica_method_id=>1,:resource_list=>resources
    file.save
          #active replication, dn't use passive
          logger.info "start to replicate..."          
          e=RFile.find(file.id,:order=>"path asc")
          logger.info "File: #{e.path}/#{e.name}\nLevel: #{e.policy.name} \n"
          e.init_replica_method
          candidate=e.get_candidate
          delete=e.get_delete
          logger.info "Candidate:#{candidate.inspect}\n"
          logger.info "Delete:#{delete.inspect}\n"
          e.replicate candidate if candidate.size>0
          e.delete_replica    
    #return "successful(secure level not implement yet)"
    #
    return e.get_secure_level resources
  end
  
  def get_policy(srbfilepath)
    path=Pathname.new srbfilepath
    file=RFile.find_by_name_and_path path.basename.to_s,path.dirname.to_s
    if file
      if file.policy.class==CustomPolicy
        return Policy.find(1).name
      else
        return file.policy.name
      end
    end
    return nil;
  end
  
  def remove_policy(srbfilepath)
    path=Pathname.new srbfilepath
    file=RFile.find_by_name_and_path path.basename.to_s,path.dirname.to_s
    if file && file.policy
      file.policy=nil
      file.save
      return true
    end
    return false
  end
  
  def list_policy
    Policy.find(:all,:conditions=>["type is null"]).collect{|p|p.name}
  end
  
  def list_policy_desc
    Policy.find(:all,:conditions=>["type is null"]).collect{|p|p.desc}     
  end

  def get_policy_desc(policyname)
    p=Policy.find(:first,:conditions=>{:name=>policyname})    
    if p 
      return p.desc
    end
    return nil
  end
  
end
