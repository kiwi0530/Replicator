require File.join(File.dirname(__FILE__), '../config/environment')

[RZone,RDomain,RUser,RResource].each do |e|
  e.sync
end

user=RUser.find :first
RResource.find(:all,:order=>'name asc').each do |r|
  result=r.can_connect?(true,user)
  p "Resource:#{r.name} online:#{r.online} downtime:#{r.downtime}"
end