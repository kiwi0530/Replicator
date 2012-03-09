// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//template cache
var TEMPLATES=$H(new Array());
//script template cache
var SCRIPTS=$H(new Array());
var CUR_JSON;
var DEBUG=true
var logger={
	info:function(msg){
		if(window.console&&console.log) console.log(msg);
	},
	debug:function(msg){
		if(window.console&&console.debug&&DEBUG) console.debug("[debug]"+msg);
	}
	
}
/*
 * 載入資料的主要程序
 * 1. 根據winddow.loaction.hash來判斷要進行什麼服務的呼叫
 * 2. 取得範本並且快取
 * 3. 取得json
 * 4. 如果有伺服器命令就優先執行
 * 4.1. 更改window.location.hash
 * 4.2. load_data()
 * 5. render template
 * 6. render script template
 */
//function load_data(url){
function load_data(url,content,options){
	if(url==null) 
	{
		//url=window.location.hash.replace(/#/,'/');			
	}
	else if(url!=""){
		//window.location.replace("#"+url.substr(1,url.length));
	}
	if(content==null) content=$('content');
	else{content=$(content)}	
	logger.debug('request '+url+' content '+content.id)		
	controller=url.split('/')[1];	
	action=url.split('/')[2];
	temp_key=controller+"_"+action
	$('message').innerHTML="";
	$('message').hide();
	//讀取範本
	if(options&&options.onInit)	options.onInit();		
	if(TEMPLATES[temp_key]==null){
		ajax=new Ajax.Request(url,{method:'get',requestHeaders:['Accept','text/html',"Cache-Control","no-cache","If-Modified-Since","0"],onSuccess:function(req){
				TEMPLATES[temp_key]=TrimPath.parseTemplate(req.responseText);
				if(options&&options.onAfterTemplate)	options.onAfterTemplate(TEMPLATES[temp_key]);			
			},onFailure:function(req){
				$('message').innerHTML+="error request template"+"<br/>";
				$('message').show();
				return false;
			},onException:function(req,e){
				$('message').innerHTML+="error request template"+e+"<br/>";
				$('message').show();
				return false;				
			} 
		});
	}	
	//讀取資料
	ajax=new Ajax.Request(url,{method:'get',requestHeaders:['Accept','application/json',"Cache-Control","no-cache","If-Modified-Since","0"],onSuccess:function(req){
			json="{}".evalJSON();
			try{
				json=req.responseText.evalJSON();
				if(content.id=='content') CUR_JSON=json;
			}
			catch(e)
			{
				$('message').innerHTML+="processing error"+e+"<br/>";
				$('message').show();
			}
			//執行伺服器端命令
			if(options&&options.onAfterJson)	options.onAfterJson(json);						
			if(json.redirect!=null) 
			{
				url=json.redirect;
				window.location.replace("#"+url.substr(1,url.length));
				load_data();
			}					
			if(json.message!=null)	
			{
				$('message').innerHTML+=json.message+"<br/>";
				$('message').show();
			}
			//render template
			for(i in json){
				eval("CONTEXT."+i+"=json."+i+";");
			}
			template=TEMPLATES[temp_key];
			if(!template) 
			{
				$('message').innerHTML+="template error"+"<br/>";
				$('message').show();
			}
			result = template.process(CONTEXT);			
			//content.innerHTML=result;
			content.innerHTML=result+content.innerHTML;
			//render script template
			//如果JS範本不存在的話就讀取，一定要在資料後方，不然會null
			//$('script_cache').innerHTML="";
			if(SCRIPTS[temp_key]==null)
			{
				//ajax=new Ajax.Request("/"+controller+"/"+action,{method:'get',evalScripts:false,requestHeaders:['Accept','text/javascript'],onSuccess:function(req){
				//ie bug: do not change content type, url must add slash
				abc=new Ajax.Request("/"+controller+"/"+action,{method:'get',requestHeaders:["Cache-Control","no-cache","If-Modified-Since","0"],onSuccess:function(req){
						SCRIPTS[temp_key]=req.responseText;					
						//eval(SCRIPTS[temp_key]);
					},onFailure:function(req,e){
						$('message').innerHTML+="error request javascript"+e+"<br/>";
						$('message').show();								
					}
				});		
			}
			else{
				eval(SCRIPTS[temp_key]);
			}	
			bind_links();			
			if(options&&options.onSuccess)	options.onSuccess(json);	

		} ,onFailure:function(req){
			$('message').innerHTML+="error request json"+"<br/>";
			$('message').show();
		},onException:function(req,e){
			$('message').innerHTML+="error request json"+e.message+"<br/>";
			$('message').show();		
		} 
	});
	return CUR_JSON.last_time;
}