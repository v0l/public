var imgs = {}

function get(){
	var igs = document.getElementsByClassName('image');
	for(var x=0;x<igs.length;x++){
		var lk = igs[x].firstChild.nodeName === 'A' ? igs[x].firstChild.firstChild.src : igs[x].firstChild.src;
		if(lk === undefined){
			debugger;
		}
		
		if(imgs[lk] === undefined){
			imgs[lk] = lk;
		}
	}
	
	if(document.body.offsetHeight <= window.scrollY + window.outerHeight){
		clearInterval(ival);
		console.log("Done");
		
		for(var z in imgs){
			console.log(imgs[z]);
		}
		return;
	}
	
	window.scrollBy(0, window.outerHeight/10);
}

var ival = setInterval(get, 100);