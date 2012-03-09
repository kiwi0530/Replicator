class StandardReplicaMethod < ReplicaMethod
  
  module ModelMethods
    
    def get_zone_candidate()
      @zone_candidate
    end
    
    def get_domain_candidate()
      self.init if !@resource_candidate
      @domain_candidate
    end
    
    def get_candidate()
      self.init if !@resource_candidate
      @resource_candidate
    end
    
    def get_delete()
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
            rescue IOException=>e
            log.success=false
          end
          log.save
        end
      end
    end
    
    def init
      info=Hash.new
      @resource_candidate||=[]
      @domain_candidate||=[]
      @zone_candidate||=[]
      self.replicas.each do |e|
        @resource_filter||=[]
        @duplicate||=[]
        
        #p "#{e.number}, #{e.resource.name}, #{e.resource.domain.name}, #{e.resource.domain.zone.name}"
        
        if @resource_filter.member? e.resource.name
          @duplicate.push e.number
        else
          zone=e.resource.domain.zone.name
          domain=e.resource.domain.name
          resource=e.resource.name
          @resource_filter.push resource
          
          if !info[zone]
            info[zone]=Hash.new
          end
          if !info[zone][domain]
            info[zone][domain]=Hash.new
          end
          if !info[zone][domain][resource]
            info[zone][domain][resource]=e.number
          end
        end  
      end
      
      delete_duplicate
      
      all_zone=RZone.find(:all)
      #      p "All has #{info.size} zones #{info.size.to_f/all_zone.size.to_f*100}%"
      zsel=select(all_zone, info.keys, calc(self.policy.zonetype, self.policy.zone, info.size, all_zone.size))
      zsel.each do |e|
        info[e]=Hash.new
        @zone_candidate.push e
      end
      #      p zsel
      
      info.keys.each do |z|
        #        all_domain=RZone.find(:first,:conditions=>{:name=>z}).domains
        all_domain=all_zone.select{|e| e.name==z}.first.domains
        #        p " Zone #{z} has #{info[z].size} domains #{info[z].size.to_f/all_domain.size.to_f*100}%"
        dsel=select(all_domain, info[z].keys, calc(self.policy.domaintype, self.policy.domain, info[z].size, all_domain.size))
        dsel.each do |e|
          info[z][e]=Hash.new
          @domain_candidate.push e
        end
        #        p dsel
        info[z].keys.each do |d|
          #          all_resource=RDomain.find(:first,:conditions=>{:name=>d}).resources
          all_resource=all_domain.select{|e| e.name==d}.first.resources
          #          p "  Domain #{d} has #{info[z][d].size} resources #{info[z][d].size.to_f/all_resource.size.to_f*100}%"
          rsel=select(all_resource, info[z][d].keys, calc(self.policy.resourcetype, self.policy.resource, info[z][d].size, all_resource.size, true))
          rsel.each do |e|
            @resource_candidate.push e
          end
          #          p rsel
          info[z][d].keys.each do |r|
            #            p "R #{r}=>#{info[z][d][r]}"
            @delete||={}
            @delete[r]=info[z][d][r]
          end
        end
      end
      #      p "Before"
      #      p @resource_candidate
      #      p @delete
      @temp_name=[]
      @resource_candidate.each do |r|
        if @delete.has_key? r
          @temp_name.push r
        end
      end
      @temp_name.each do |r|
        @delete.delete r if @delete.has_key? r
        @resource_candidate.delete r if @resource_candidate.member? r
      end
      #      p "After"
      #      p @resource_candidate
      #      p @delete
      
      # Block List
      [
        "01_grid4_NTTU"
      ].each do |block|
        @resource_candidate.delete block if @resource_candidate.member? block
      end
      
    end
    
    def calc (type, need, size, all, resource=false)
      percent=(size.to_f/all.to_f)*100
      more=0
      if type == "percent"
        if resource
          more=(need.to_f/100*all).ceil
        else
          if percent.to_f < need.to_f
            more=((need.to_f-percent.to_f)/100*all).ceil
          end
        end
      else
        if resource
          more=need
        else
          if size < need
            more=(need-size).ceil
          end
        end
      end
      more
    end
    
    def select(all, exist, qty)
      return [] if all.size == 0
      free=[]
      cad=[]
      all.each do |e|
        if !exist.include? e.name
          free.push e.name
        end
      end
      if all[0].class.to_s == "RResource"
        all=all.sort {|a,b| b.downtime <=> a.downtime}
        while qty>0 and all.size>0
          pop=all.pop
          if pop.online
            cad.push pop.name
          end
          qty=qty-1
        end
      else
        while qty>0 and free.size>0
          i=rand free.size
          cad.push free[i]
          free.delete_at i
          qty=qty-1
        end
      end
      cad
    end
    
    def delete_duplicate
      @duplicate.each do |e|
        begin
          self.file(e).delete
          rescue IOException=>e
        end
      end
    end
  end  
end