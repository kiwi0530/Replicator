class CustomReplicaMethod < ReplicaMethod
  module ModelMethods
    def get_zone_cadidate()
      @zone_candidate
    end
    
    def get_domain_candidate()
      @domain_candidate
    end
    
    def get_candidate()
      @resource_candidate
    end
    
    def get_delete
      @delete
    end
    
    def delete_replica
      return if @delete.size==0
      @delete.keys.each do |k|
        if @delete[k]!="0"
          log=ReplicaLog.new
          log.file_id=self.id
          log.action="Delete"
          log.resource=k
          begin
            self.file(@delete[k]).delete
            log.success=true
            rescue =>e
            log.success=false
          end
          log.save
        end
      end      
    end
    
    def get_secure_level(resource_list)
      # Build Tree
      tree=Hash.new
      resource_list.split(',').each do |e|
        res=RResource.find :first,:conditions=>{:name=>e}
        zone=res.domain.zone.name
        domain=res.domain.name
        resource=res.name
        tree[zone]||=Hash.new
        tree[zone][domain]||=Array.new
        tree[zone][domain].push resource
      end

      # zone 
      all_zone_count=RZone.count
      zone_count=tree.keys.size
      zone_level=Hash.new
      zone_level["number"]=zone_count
      zone_level["percent"]=(zone_count.to_f/all_zone_count.to_f)*100
      domain_level=Hash.new
      domain_level["percent"]=100
      resource_level=Hash.new
      resource_level["percent"]=100
      
      domain_level_count=0
      resource_level_count=0
      
      # domain
      tree.each do |zone_name, domains|
        all_domain_count=RZone.find(:first, :conditions=>{"name"=>zone_name}).domains.size
        domain_count=domains.size
        domain_percent=(domain_count.to_f/all_domain_count.to_f)*100
        #puts "DOMAIN in #{zone_name}"
        #p all_domain_count
        #p domain_count
        #p domain_percent
        if domain_level_count == 0
          domain_level["number"]=domain_count
          domain_level["percent"]=domain_percent
        #elsif domain_level["number"] < domain_count ||domain_level["percent"] < domain_percent
        else
          #domain_level["number"]=domain_count
          #domain_level["percent"]=domain_percent
          domain_level["number"]=(domain_level["number"].to_f*domain_level_count+domain_count.to_f)/(domain_level_count+1)
          domain_level["percent"]=(domain_level["percent"]*domain_level_count+domain_percent)/(domain_level_count+1)
        end
        domain_level_count=domain_level_count+1
        
        # resource
        domains.each do |domain_name, resources|
          all_resource_count=RDomain.find(:first, :conditions=>{"name"=>domain_name}).resources.size
          resource_count=resources.size
          resource_percent=(resource_count.to_f/all_resource_count.to_f)*100
          #puts "RESOURCE in #{domain_name}"
          #p all_resource_count
          #p resource_count
          #p resource_percent
          if resource_level_count == 0
            resource_level["number"]=resource_count
            resource_level["percent"]=resource_percent
          #elsif resource_level["number"] < resource_count || resource_level["percent"] < resource_percent
          else
            #resource_level["number"]=resource_count
            #resource_level["percent"]=resource_percent
            resource_level["number"]=(resource_level["number"].to_f*resource_level_count+resource_count.to_f)/(resource_level_count+1)
            resource_level["percent"]=(resource_level["percent"]*resource_level_count+resource_percent)/(resource_level_count+1)
          end
          resource_level_count=resource_level_count+1
        end
      end
      
      #p zone_level
      #p domain_level
      #p resource_level
      
      # Policy?
      secure_level = nil
      (2..6).each do |e|
        p=Policy.find_by_id e
        if zone_level[p.zonetype] >= p.zone
          if domain_level[p.domaintype] >= p.domain
            if resource_level[p.resourcetype] >= p.resource
              secure_level||=p.name
            end
          end
        end
      end
      secure_level
    end
    
    def init
      @resource_candidate||=[]
      @domain_candidate||=[]        
      @zone_candidate||=[]
      
      return if !self.policy.resource_list
      
      self.policy.resource_list.split(',').each do |e|
        @resource_candidate.push e
      end

      @delete||={}
      self.replicas.each do |r|
        @delete[r.resource.name]=r.number if !@resource_candidate.member?(r.resource.name)
      end
      
      self.replicas.each do |e|
        @resource_candidate.delete e.resource.name if @resource_candidate.member? e.resource.name
      end
      
      @resource_candidate.each do |e|
        resource=RResource.find :first,:conditions=>{:name=>e}
        @domain_candidate.push resource.domain.name
        @zone_candidate.push resource.domain.zone.name
      end
      @domain_candidate.uniq
      @zone_candidate.uniq
      

    end
  end  
end