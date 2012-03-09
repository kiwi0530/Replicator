class ReplicatorApi < ActionWebService::API::Base
  api_method :set_policy,:expects=>[{:srbfilepath=>:string},{:policy=>:string},{:owner=>:string}],:returns=>[:bool]
  api_method :set_custom_policy,:expects=>[{:srbfilepath=>:string},{:resources=>:string},{:owner=>:string}],:returns=>[:string]  
  api_method :get_policy,:expects=>[{:srbfilepath=>:string}],:returns=>[:string]
  api_method :remove_policy,:expects=>[{:srbfilepath=>:string}],:returns=>[:bool]  
  api_method :list_policy,:returns=>[[:string]]  
  api_method :list_policy_desc,:returns=>[[:string]]    
  api_method :get_policy_desc,:expects=>[{:policyname=>:string}],:returns=>[:string]      
end
