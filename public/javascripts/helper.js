CONTEXT={};
var global_anchor_onclick=function(e){
	a=Event.element(e);
	if(a.href.indexOf('#')>0 && a.target=='') 
	{
		window.location.replace(a.href);				
		load_data();
	}
}

function bind_links(){
	try{
	$$('a').each(function(a){
		//避免重複掛上事件
		Event.stopObserving(a,'click',global_anchor_onclick);
		if(a.href.indexOf('#')>0) 
		{
			Event.observe(a,'click',global_anchor_onclick);	
			//logger.debug(a.inspect()+" bound global_anchor_onclick");
		}
	});
	}catch(e){alert(e.message)}	
}
/* not good for ie
function bind_events(events){	
	alert(events);	
	if(!events) return;
	try{
		debugger;
	events=$H(events);
	events.each(function(pair){
		Event.observe(pair.key,'click',pair.value);
		//logger.debug(name+" bound click_event");		
	});
	}catch(e){alert(e.message)}
}*/

function redirect_to(path){
	window.location.replace(path);
	load_data();
}
function show_msg(msg){
	$('message').innerHTML=msg;
	$('message').show();
}

function Tab(array){
	//public
	this.activate=function(anchor){
		href=window.location.hash;
		key=href.replace(/#/,"/")+'-'+array[0];
		reset();
		if(name=COOKIE.getCookie(key)) 
		{
			$(name+"_tab").className="c_tab_body_active";
			$(name).className="active";					
		}
		else{
			$(anchor+"_tab").className="c_tab_body_active";
			$(anchor).className="active";		
		}
	}
	
	//private
	var anchors=array;
	var reset=function(){
		anchors.each(function(a){		
			$(a).className="";
			$(a+"_tab").className='c_tab_body';
		});
	}
	//constructor
	array.each(function(a){
		Event.observe(a,"click",function(e){
			reset();
			id=Event.element(e).id;
			$(id+"_tab").className="c_tab_body_active";
			$(id).className="active";
			key=window.location.hash.replace(/#/,'/')+'-'+array[0];			
			COOKIE.setCookie(key,id)
		});
	});
}

