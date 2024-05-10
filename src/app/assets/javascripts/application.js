// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3 
//= require jquery-ui 
//= require dataTables/jquery.dataTables
//= require dataTables/extras/dataTables.colReorder
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require tether 
//= require_tree .


/*function add_autocomplete_select_event(text_field){

 $("#ontop_autocomplete_container").on("click", ".list-group-item", function(){
   var res = $(this).html().split(" ")
   var all_tags = JSON.parse($("#all_tags_json").val())
   var text = $(text_field).val()
   //console.log("text:" + text)
   var last_tag = all_tags[all_tags.length-1]
   var t = last_tag.val.split(":")
   var new_tag = ''
   if (last_tag.type == 'gene'){
     new_tag = [t[0], res[0]].join(":")
   }else{
     new_tag = last_tag.val
   }
   console.log("last_tag val: " + last_tag.val)
   console.log("new_tag: " + new_tag)
   var new_text = text.substring(0, text.length-last_tag.val.length) + new_tag
   console.log(text + " => " + new_text)
   all_tags[all_tags.length-1] = {type: last_tag.type, val: new_tag}
   upd_tag_fields(all_tags)
   $("#all_tags_json").val(JSON.stringify(all_tags))
   $(text_field).val(new_text)
   $("#ontop_autocomplete_window").addClass("hidden").hide()
   $(text_field).focus()
 })

}*/

/*function upd_tag_fields(all_tags){
   var tag_types = ['tag', 'gene']
    for(var i=0; i< tag_types.length; i++){
        var tag_type = tag_types[i]
        console.log(tag_type)
        $("#list_" + tag_type + "s").html(all_tags.filter(x => x.type==tag_type).map(x => ("<span class='badge badge-light'>" + x.val.substring(1) + "</span>")).join(" "))
    }
    }*/

function display_tag(match, pos, index, all_tags){
    console.log([match, pos, index].join(" -- "))
    var tag = all_tags[index]
    var html = ''
    if (tag){
	switch(tag.type) {
	case 'gene':
	    html = "<span class='badge badge-light badge-tag gene_tag gene_id_" + tag.id + "'>" + tag.label + "</span>"
	    // "<sup><a href='https://flybase.org/reports/" + tag.val + "'><i class='fa fa-link'></i></a></sup>"
	    break;
	case 'tag':
	    html = "<span class='badge badge-light'>" + tag.val.replace(/_/g, " ") + "</span>"
	    break;
	case 'link':
//	    var tmp_t = tag.tag.split("|")
//	    if (tmp_t.length == 2){
	//	html = "<a href='" + tmp_t[1].replace(/_/g, " ") + "'><span class='badge badge-light'>" + tmp_t[0].replace(/_/g, " ") + "</span></a>"
		html = "<a href='" + tag.url + "'><span class='badge badge-light'>" + tag.text + "</span></a>"
//	    }
	    //	    var html = "<a href='" + tag.url.replace(/_/g, " ") + "'><span class='badge badge-light'>" + tag.text.replace(/_/g, " ") + "</span></a>"
	    break;
	case 'pmid': // case 'PMID':
	    html = "<a href='https://pubmed.ncbi.nlm.nih.gov/" + tag.val + "'>[Ref]</a>" 
	    break;
	case 'doi': //case 'DOI':
            html = "<a href='https://doi.org/" + tag.val + "'>[DOI link]</a>"
            break;
	case 'hidden':
	    html = ""	    
	    break;
	}
    }
    console.log( "HTML=" + html)
    return html
}

function upd_assertion_display(assertion, assertion_display_container){
    var html= assertion
    var all_tags = JSON.parse($("#all_tags_json").val())
    var index = -1
//    html = assertion.replace(/\#[\d\w\-_\=\>\:\|\/]*|\#link[.\d\w\-\=\>_\:\|\/]*/g,function(match, pos){
     html = assertion.replace(/(\#link[^\s]*)|(\#doi[^\s]*)|(\#[\d\w\-\=\>_\:\|\/]*)/g,function(match, pos){
	index++
	return display_tag(match, pos, index, all_tags)
    });
    $(assertion_display_container).html(html)
}

function upd_tags(e, text_field, autocomplete_url_base, do_autocomplete){
    var full_text = $(text_field).val()
    var all_tags = []
    var res = null

    var existing_tags = JSON.parse($("#all_tags_json").val())
    var h_existing_tags = {}
    for (var i=0; i< existing_tags.length; i++){
        if (!h_existing_tags[existing_tags[i]]){
            h_existing_tags[existing_tags[i]] = []
        }
        h_existing_tags[existing_tags[i]].push(i)
    }
    
    console.log("existing_tags: " + JSON.stringify(existing_tags))
    var tag_i = 0
    
    var cursor_pos = (e) ? e.target.selectionStart : null
    $("#cursor_pos").val((cursor_pos) ? cursor_pos : '')
    console.log("Cursor position: " + cursor_pos)
    // var after_text = full_text.substring(cursor_pos, full_text.length)
    var text = (cursor_pos) ? full_text.substring(0, cursor_pos) : full_text
    changed_tag_i =0
    console.log("text: " + full_text + "----" + text)
    var removed_tag = false
    if(res = full_text.match(/(\#link[^\s]*)|(\#[dD][oO][iI][^\s]*)|(\#[\d\w\-\=\>_\:\|\/]*)/g)){
/*	h_res = {}
	for (var i=0; i< res.length; i++){
	    if (!h_res[res[i]]){
		h_res[res[i]] = []
	    }
	    h_res[res[i]].push(i)
	}
*/	
	for (var i=0; i< res.length; i++){
	    var item = res[i]
	    var t = item.split(":")
	    t[0] = t[0].toLowerCase()
            var val_t = []
	    for (var j=1; j<t.length; j++){
		val_t.push(t[j])
            }
	    var val = val_t.join(":")
	    var mod_item = t[0] + ":" + val
	    console.log("val: "+ val)
	    var re = new RegExp("^" + mod_item, "g")
	    while (existing_tags.length > res.length && existing_tags[tag_i] && !existing_tags[tag_i].tag.match(re)){
		console.log("add tag_i: " + tag_i)
		removed_tag = true
                tag_i++ // just removed a hashtag => need to shift
	    }
	    console.log("tag_i: " + tag_i)
            if (existing_tags[tag_i] && existing_tags[tag_i].tag == mod_item){
		all_tags.push(existing_tags[tag_i])
		tag_i++
	    }else{
		if (existing_tags.length <= res.length 
		    || (existing_tags[tag_i].tag != mod_item && existing_tags[tag_i].tag.match(re)) 
		   ){
		    changed_tag_i = all_tags.length
     console.log("itiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
		   console.log(t)
		    if (t[0] == '#gene' && t.length > 1){		
			all_tags.push({val : val, type : "gene", tag : mod_item})
			// console.log("add tag: " + item.id)
		    }else{
			if (t[0] == '#link' && t.length > 2){
			    tmp_t = mod_item.split("|")
			    if (tmp_t.length == 2){
				all_tags.push({type: "link", tag: mod_item, val: item.substring(1, mod_item.length), text : tmp_t[0].replace(/_/g, " "), url : tmp_t[1].replace(/_/g, " ")})
				//text: tmp_t[0], url: tmp_t[1]})
				//	all_tags.push({type: "link", text: tmp_t[0], url: tmp_t[1]})
			    }
			 //   all_tags.push({type: "link", val : item.substring(1, item.length), tag : item})
			}else{
			    if (t[0] == '#hidden' && t.length > 1){
				all_tags.push({type: "hidden", val : t[1], tag : mod_item}) 
			    }else{
				if (t[0] == '#pmid' && t.length > 1){
				    all_tags.push({type: "pmid", val : t[1], tag : mod_item})
				}else{
				    if (t[0] == '#doi' && t.length > 1){
					all_tags.push({type: "doi", val : t[1], tag : mod_item})
					console.log({type: "doi", val : t[1], tag : mod_item})
				    }else{
					all_tags.push({val : mod_item.substring(1, item.length), type : "tag", tag : mod_item})
				    }
				}
			    }
			}
		    }
		    if (existing_tags.length == res.length){
			tag_i++
		    }
		}
	    }
	}
	
	// save all_tags
	$("#all_tags_json").val(JSON.stringify(all_tags))
	
        if (do_autocomplete){
console.log("do_autocomplete:" + do_autocomplete)	    
	    //   var last_match = res[res.length-1]
	    //    if (last_match){
	    //	var sub = text.substring(text.length-last_match.length, text.length)
	    //console.log("current text: " + text)
	    //console.log("last_match lenght: " + (text.length-last_match.length) + " : " + last_match.length)
	    //console.log("checking... " + last_match + " vs. " + sub)
	    //	if (last_match == sub){
	    if(removed_tag == false)
		//console.log("checking last match... " + all_tags[all_tags.size-1])
		//   if (last_match == h_lists.genes[h_lists.genes.length-1]){
            console.log("not removed_tag")
	    console.log(all_tags[changed_tag_i])
		if(all_tags[changed_tag_i] && all_tags[changed_tag_i].type == 'gene'){
		    console.log("gene tag")
		    var new_t = []
                    var t = all_tags[changed_tag_i].val.split(":")
		    for (var j=1; j< t.length; j++){
			new_t.push(t[j])
		    }
		    var term = new_t.join(":")
			//console.log("match last gene!!" + last_match)
		    var url = autocomplete_url_base + "&term=" + term + "&organism=" + t[0]
		    //console.log(url)
		    var offset = $( text_field ).offset();
		    $.get(url, function( data ) {
			if (data){
			    console.log("display choices")
			    $("#ontop_autocomplete_window").removeClass("hidden")
			    $("#ontop_autocomplete_container").empty()
			    $("#ontop_autocomplete_container").html("<ul class='list-group pointer'>" + data.map(e => "<li id='gene-id_" + e.id + "' class='list-group-item'>" + e.label + "</li>").join("") + "</ul>")
			    $("#ontop_autocomplete_window").css({
				left: offset.left,
				width: $(text_field).width(),
				height:'auto',
				top: offset.top + $( text_field ).height() + 15
			    }).stop().show(100);
			}
		    })
		}
	}else{
	    //console.log("close autocomplete window...")
	    $("#ontop_autocomplete_window").addClass("hidden").hide()
	}
        //    }
	//}
	//    var list_k = Object.keys(h_lists)
   //     upd_tag_fields(all_tags)
    }
    
}


function unselect_assertion(){
    var current_assertion_id = $("#selected_assertion_id").val()
    if (current_assertion_id != ''){
	var assertion_text = $("#assertion_li_" + current_assertion_id).find(".assertion-content").first()
	$(assertion_text).css({'text-decoration' : 'none', 'font-weight' : 'normal'})
    }
}

function add_margin_content_container(){
    var  w = $(window).width()
    var form_window = $("#side_panel")
    if (!form_window.hasClass("hidden")){
	var ww = '600px'; 
	console.log("bla")
	$("#content_container").animate({
	    'margin-right': ww
	}, 200);
	
    }else{
	$( "#content_container" ).animate({
	    'margin-right': 0
	}, 200);
    }
}

function place_side_panel(){
    
    var w = $(window).width()
    var ww = 600;
    
    $("#side_panel").removeClass("hidden")
    
    $("#side_panel").animate({
	'top' : 100,
	'width' : ww,
	'left' : w - ww,
	'bottom' : 10
    }, 200, function(){
    })

    if (! $("#side_panel").hasClass("hidden")){
	add_margin_content_container()
    }
}

 function adjust_windows(){
  var h = $(window).height()
  var w = $(window).width()
  if (!$("#side_panel").hasClass("hidden")){
   $("#side_panel").css({'height' : h - 110})
   place_side_panel();
  }
 }

function refresh(container, url, h){
    var div= $("#" + container);
    var width = $(div).width();
    var height = $(div).height();
    var xhr = $.ajax({
        url: url,
        type: "get",
        dataType: "html",
        beforeSend: function(){
            if (h.loading || h.loading_full){
                div.empty()
                if (h.loading){
                    $("#" + container).html("<div style='width:" + width + "px;height:" + height + "px' class='loading'><div class='loading-content'><i class='fa fa-spinner fa-pulse fa-fw fa-lg " + h.loading + "'></i><\
/div></div>")
                }else{
                    if(h.loading_full){
                        $("#" + container).html(h.loading_full)
                    }
                }
            }
        },
        success: function(returnData){
            if (container){
                if (container != 'step_container' || (container == 'step_container' && $(".run_container").length == 0) || ($("#dr_plot").length > 0 && container == 'plot_container')){
                    if (!h['step_id'] || $("li#step_" + h['step_id']).hasClass('active')){
                        if ($("#dr_plot").length > 0 && container == 'plot_container'){
                            Plotly.purge("dr_plot");
                        }
                        div.empty()
                        div.html(returnData);
                    }
                }
            }else{
                eval(returnData)
            }
        },
       error: function(e){
            //  alert(e);                                                                                                                                                                                                  
        }
    });

    return xhr

}

function refresh_post(container, url, data, method, h){
    console.log(container, url, data)
    console.log("biiiiiiiiiiii")
    if (h.redirect === undefined){
        h.redirect = false
    }
    if (h.multipart === undefined){
        h.multipart = false
    }
    var div= $("#" + container)
    var width = $(div).width();
    var height = $(div).height();
    console.log(method)
    var h2 = {
        url: url,
        type: method,
        dataType: "html",
        data: data,
        beforeSend: function(){
             if (h.loading || h.loading_full){
                div.empty()
                if (h.loading){
                    $("#" + container).html("<div style='width:" + width + "px;height:" + height + "px' class='loading'><div class='loading-content'><i class='fa fa-spinner fa-pulse fa-fw fa-lg " + h.loading + "'></i><\
/div></div>")
                }else{
                    if(h.loading_full){
                        $("#" + container).html(h.loading_full)
                    }
                }
            }
        },
        success: function(returnData){
            if (container){
                if (h.redirect == false){
                    if ($("#dr_plot").length > 0 && container == 'plot_container'){
                        Plotly.purge("dr_plot");
                    }
                    if (!h.not_upd_if_empty || (returnData && returnData.trim().length != 0)){
			div.empty()
			div.html(returnData);
                    }else{
                    }
                }else{
                    eval(returnData)
                }
            }else{
                eval(returnData)
            }
        },
        error: function(e){
            //    alert(e);                                                                                                                                                                                                 
        }
    }

    if (h.multipart == true){
        h2.processData = false;
        h2.contentType = false;
	h2.enctype = 'multipart/form-data';
    }
    
    $.ajax(h2);

}
