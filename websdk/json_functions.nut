/*
	PHP SDK server for Liberty Unleashed, by Rhytz
	json_functions.nut - Contains custom JSON encoding and decoding functions
	(c) 2016
*/


/*
	json_encode( table/array )
	
	Takes a table/array and encodes it into JSON
*/
function json_encode( table ){
	if(typeof(table) == "table" || typeof(table)  == "array"){
		json <-  "{";
		json_recurse( table );
		json += "}"; 
		return json;
	}else{
		return false;
	}
}

/*
	json_recurse( table/array )
	
	Recursive function that loops through all layers of a table/array and encodes it.
	Used by json_encode(). 
*/
function json_recurse( table ){
	local len = table.len();
	local i = 1;
	local typ = typeof(table);
	
	//Loop through all keys in the supplied table
	foreach (key, value in table) {
		//Switch datatype of 'value' for appropriate handling
		switch (typeof(value)){
			//If the datatype is another array or table, run the function again
			case "array":
				json += "\"" + key + "\": [";
				json_recurse( value );
				json += "]";	
				break;
				
			case "table":
				json += "\"" + key + "\": {";
				json_recurse( value );
				json += "}";
				break;
				
			//Handling of other datatypes
			case "bool":
				local boolvalue = value ? "true" : "false";
				//Depending on whether the current current 'table' is an array or table, change markup.
				typ == "array" ? json += boolvalue : json += "\"" + key + "\": " + boolvalue;			
				break;
				
			case "integer":
				typ == "array" ? json += value : json += "\"" + key + "\": " + value; 
				break;
				
			case "float":
				typ == "array" ? json += value : json += "\"" + key + "\": " + value; 
				break;
				
			case "null":	
				typ == "array" ? json += "null" : json += "\"" + key + "\": " + "null";
				break;
				
			case "string":
				typ == "array" ? json += "\"" + json_escape(value) + "\"" : json += "\"" + key + "\":\"" + json_escape(value) + "\"";
				break;
			
			//Return false if the datatype is unsupported
			default:
				typ == "array" ? json += "false" : json += "\"" + key + "\": " + "false";
				break; 
		}
		
		//Append a comma at the end if it isn't the last item in the current table/array
		if(i < len){
			json += ",";
		}
		i++;
	}
}

/*
	json_escape( unescaped string )
	
	Puts a backslash in front of any double quotes in the input string.
*/
function json_escape( string ){
	
	//Split the input string on any double quotes
	local breaks = split( string, "\"" );
	local outputstring = "";
	
	foreach (key, value in breaks) {
		if(key > 0){
			//Append backslash
			outputstring += "\\\"" + value;
		}else{
			outputstring += value;
		}
	}	

	return outputstring;
}

/*
	json_decode( JSON string )
	
	Squirrel supports JSON syntax to create tables.
	This function compiles the input string to Squirrel code. 
	Use with EXTREME caution and properly filter any user input, because it will also compile and execute any unescaped malicious code within the string.
*/
function json_decode( string ){
	string = strip( string );
	local json = ::compilestring("return " + string);
	return json();
}