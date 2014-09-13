//#####################################################
//# jQuery AJAXfetch v0.10.2; 2013-July-9
//# http://phrogz.net/JS/AJAXFetch/
//# 
//# Copyright (c) 2008-2013 Gavin Kistner (phrogz.net)
//# Licensed under the MIT License
//#####################################################
(function($){
	
	var theActions=[
		{name:'swap',         method:'replaceWith'          },
		{name:'insertbefore', method:'before'               },
		{name:'insertafter',  method:'after'                },
		{name:'remove',       method:'remove',  noarg:true  },
		{name:'append',       method:'append',  parent:true },
		{name:'prepend',      method:'prepend', parent:true }
	];
	var theCriteria=$.map(theActions,function(inAction){ return".ajaxfetch-and"+inAction.name; }).join(",");

	var theInitializer=function(){
		var theSource=$(this);
		var theHandler=function(inEvent){
			if (inEvent.type=='dblclick'){
				// Clear text selection, for IE
				if(document.selection && document.selection.empty){
					document.selection.empty();
				}else if(window.getSelection){
					window.getSelection().removeAllRanges();
				}
			}
			if(!inEvent.cancelFurtherSubmits){
				theSource.ajaxfetch();
				return false;
			}
		};
		if(theSource.is('form')){
			theSource.submit(theHandler);
			theSource.find(':submit').click(function(){this.form._afB=this});
		}else if(theSource.is('a')){
			theSource.click(theHandler);
		}else{
			var theEventRE=/ajaxfetch-on(\w+)/;
			var theEventMatch=this.className.match(theEventRE);
			var theEvent=theEventMatch?theEventMatch[1]:'dblclick';
			if (theEvent!='manual') theSource.bind(theEvent,theHandler); // 'manual' callbacks call .ajaxfetch() on the source
		}
	};
	
	$.each(theActions,function(_,info){
		$.fn["ajaxfetch_and"+info.name]=function(inReferenceElement,inURL){
			return this.ajaxfetch_and(function(inNewJNode){
				var theReferenceElement = inReferenceElement || document.getElementById(this.getAttribute('ajaxfetch-'+info.name)) || (info.parent ? this.parent : this);
				if(info.noarg){
					$(theReferenceElement)[info.method]();
				}else{
					$(theReferenceElement)[info.method](inNewJNode);
					inNewJNode.find(theCriteria).andSelf().filter(theCriteria).each(theInitializer);
				}
			},inURL);
		};
	});
	
	$(function(){
		$(theCriteria).each(theInitializer);
	});
	
	$.fn.ajaxfetch=function(){
		var theActionRE=/ajaxfetch-and\w+/;
		return this.each(function(){
			var theSource=$(this);
			var theActionMatch=this.className.match(theActionRE);
			var theAction=theActionMatch&&theActionMatch[0].replace('-','_');
			if(theSource[theAction]){
				theSource[theAction]();
			}else{
				if (window.console) console.log("Ignoring unrecognized ajaxfetch command: '"+theAction+"'");
			}
		});
	};
	
	$.fn.ajaxfetch_and=function(inCallback,inURL){
		return this.each(function(){
			var self=this,jthis=$(this);
			var theURL=inURL||this.getAttribute('action')||this.getAttribute('href');
			var theScopedCallback=function(inNodeHTML){
				if (jthis.is('form') && jthis.hasClass('ajaxfetch-andreset')) jthis[0].reset();
				return inCallback.call(self,$(inNodeHTML));
			};
			if(!inURL&&(jthis.is('form')||jthis.hasClass('ajaxfetch-asform'))){
				var theParams=(jthis.is('form') ? jthis : jthis.find('input,textarea,select')).serialize();
				theParams+=(this._afB?('&'+this._afB.name+'='+escape(this._afB.value)):'')+'&ajaxfetch='+(new Date)*1;
				var theMethod=jthis.attr('method').toLowerCase() || 'get';
				if(theMethod=='get'){
					var theURL=jthis.attr('action').replace(/\?.*/,'?'+theParams);
					$.get(theURL,theScopedCallback,'html');
				} else if(theMethod=='post'){
					$.post(jthis.attr('action'),theParams,theScopedCallback,'html');
				}
			}else{
				var theURL=inURL||this.getAttribute('href');
				// Random date to work around bug with IE over-caching AJAX info.
				theURL+=((theURL.indexOf('?')==-1)?'?':'&')+"ajaxfetch="+(new Date)*1;
				$.get(theURL,theScopedCallback,'html');
			}
		});
	};
	
	jQuery.fn.ajaxfetch_reload=function(){
		var theReloadAttribute='ajaxfetch-reloadfrom';
		return this.each(function(){
			if(this.hasAttribute(theReloadAttribute)){
				var j = $(this);
				var u = this.getAttribute(theReloadAttribute);
				j.ajaxfetch_andswap(null,u);
			}
		});
	};
	
})(jQuery);
