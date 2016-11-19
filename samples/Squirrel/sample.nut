const FILE_PATH 	= "Scripts/Rhytz/websdk/";

function onScriptLoad(){
	dofile(FILE_PATH + "websdk.nut");
	print("loaded sample file");
	//Register the functions to be called from the PHP script.
	RegisterWebCallbackFunc("Cash", Web_Cash);
	RegisterWebCallbackFunc("GetWeather", Web_GetWeather);
	RegisterWebCallbackFunc("SetWeather", Web_SetWeather);

}

function Web_Cash(data){
	local playerID = data["playerID"].tointeger();

	//Find the player by the ID
	local player = FindPlayer(playerID);
	//If the player was found
	if(player){
		//Check if the passed Value parameter is an integer
		local value = data["value"].tointeger();
		if(value){
			//Set the player cash to the supplied value
			player.Cash = data["value"];
			//Report success to the PHP script
			return true;
		//If the value parameter is not an integer
		}else{
			//Get the current cash of the player
			local Cash = { Cash = player.Cash };
			//Return the value to the PHP script
			return Cash;
		}
	//If the player was not found
	}else{
		//Report failure to the PHP script
		return false;
	}
}




function Web_GetWeather(data){
	local Weather = {
		WeatherID = GetWeather()
	}
	return Weather;
}



function Web_SetWeather(data){
	local weatherID = data["id"].tointeger();
	SetWeather(weatherID);
	return true;
}

function onPlayerCommand( pPlayer, szCommand, szText )
{
	if ( szCommand == "website" )
	{
		DataToSend <- { "command" : szCommand, "text": szText };
		WebRequest("mydomain.com", 2037, "/serverrequest.php", ResponseFromTheWebsite, DataToSend);
	}
 
	return 1;
}				

function ResponseFromTheWebsite(data){
	print(data["success"]);
}
