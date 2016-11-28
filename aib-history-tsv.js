var out = [];
var delim = "\t"
var rows = document.querySelectorAll('.ht-row');
for(var x =1; x< rows.length; x+=2) {
	var r = [rows[x].children[0].innerText, rows[x].children[1].innerText, rows[x].children[2].innerText, rows[x].children[3].innerText, rows[x].children[4].innerText];
	out[out.length] = r.join(delim); 
} 
out.join("\n");