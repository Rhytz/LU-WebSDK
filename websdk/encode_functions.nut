/*
	PHP SDK server for Liberty Unleashed, by Rhytz
	encode_functions.nut - Contains custom URL encoding functions
	(c) 2016
*/

/*
	postdata_encode( table )
	
	Converts a Squirrel table or array to POST-able data
*/
function postdata_encode( table ) {
	if(typeof(table) == "table" || typeof(table)  == "array"){
		postdata <-  "";
		keyname <- "";
		postdata_recurse( table );
		
		return postdata;
	}else{
		return false;
	}
}

/*
	postdata_recurse( table )
	
	Recursive function that loops through the table/array and encodes it. 
	Complementary function to postdata_encode().
*/
function postdata_recurse( table, depth = 0 ) {
	local len = table.len();
	local i = 1;
	local typ = typeof(table);
	//Loop through all keys in the supplied table
	foreach (key, value in table) {
		//Switch datatype of 'value' for appropriate handling
		switch (typeof(value)){
			//If the datatype is another array or table, run the function again
			case "array":
			case "table":					
				depth == 0 ? keyname  = key : keyname += "[" + key + "]";				
				postdata_recurse( value , depth + 1);	
				break;
				
			//Handling of other datatypes
			case "bool":
				local boolvalue = value ? "true" : "false";
				depth == 0 ? postdata += key + "=" + boolvalue : postdata += keyname + "[" + key + "]=" + boolvalue;
				break;
				
			case "integer":				
			case "float":
				depth == 0 ? postdata += key + "=" + value : postdata += keyname + "[" + key + "]=" + value;
				break;
				
			case "null":	
				depth == 0 ? postdata += key + "=0"  : postdata += keyname + "[" + key + "]=0";
				break;
				
			case "string":
				depth == 0 ? postdata += key + "=" + urlencode(value) : postdata += keyname + "[" + key + "]=" + urlencode(value);				
				break;
			
			//Return false if the datatype is unsupported
			default:
				depth == 0 ? postdata += key + "=false" : postdata += keyname + "[" + key + "]=false";
				break; 
		}
		
		//Append a ampersand at the end if this isnt the last item in the table
		if(i < len){
			postdata += "&";
		}
		
		i++;
	}
}


/*
	urlencode( string )
	
	Percent-encodes reserved URI characters in given string, and returns encoded string 
*/
function urlencode( string ) {
	local out = "";
	for(local i=0; i<string.len(); i++){
		local c = string.slice(i, i+1);
		switch(c){
			case " ":
				out += "%20";
				break;	
			case "!":
				out += "%21";
				break;	
			case "#":
				out += "%23";
				break;		
			case "$":
				out += "%24";
				break;		
			case "&":
				out += "%26";
				break;				
			case "'":
				out += "%27";
				break;		
			case "(":
				out += "%28";
				break;		
			case ")":
				out += "%29";
				break;	
			case "*":
				out += "%2A";
				break;	
			case "+":
				out += "%2B";
				break;			
			case ",":
				out += "%2C";
				break;		
			case "/":
				out += "%2F";
				break;										
			case ":":
				out += "%3A";
				break;		
			case ";":
				out += "%3B";
				break;						
			case "=":
				out += "%3D";
				break;	
			case "?":
				out += "%3F";
				break;	
			case "@":
				out += "%40";
				break;	
			case "[":
				out += "%5B";
				break;	
			case "]":
				out += "%5D";
				break;					
			default:
				out += c;
				break;		
		}
	}
	return out;
}
