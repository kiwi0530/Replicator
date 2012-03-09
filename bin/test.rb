
#a = Thread.new do
#  Thread.stop
#  i=20
#  while i>0
#    puts i
#    sleep 1
#    i=i-1
#  end
#end
#a.run
#timeout=10
#while timeout>0
#  break if a.status == false
#  sleep 1
#  timeout=timeout-1
#end
#a.kill
#a.join