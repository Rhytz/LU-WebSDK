/*
	PHP SDK server for Liberty Unleashed, by Rhytz
	server.nut - contains main functionality
	(c) 2016
*/


//Replace SecureKey123 with a custom hash/password to prevent others from accessing your server
const SECURE_KEY	= "SecureKey123";

//Replace with the IP of your webserver
const SECURE_IP 	= "212.238.172.246";

//On what port should the server listen to requests from your PHP script?
const LISTEN_PORT	= 2302;

//Path to the script files
const FILE_PATH 	= "Scripts/Rhytz/websdk/";

//Keeps track of active secure connections to the LU server, do not change.
SecureConnections	<- {};

//Keeps track of online players, used for CurrentPlayers request, do not change.
OnlinePlayers		<- [];

//A table of timers to keep track of timeouts
TimeoutTimers		<- {};

RegisteredFunctions <- {};


print( "- Loaded PHP SDK server by Rhytz -" );

dofile( FILE_PATH + "json_functions.nut" );
dofile( FILE_PATH + "encode_functions.nut" );

WebSocket <- NewSocket( "ReceiveData" );

//SetLostConnFunc doesn't seem to work properly now, if SetNewConnFunc is set as well. Switching them around makes only SetLostConnFunc work and vice versa.
WebSocket.SetLostConnFunc( "Failure" );		
WebSocket.SetNewConnFunc( "Connected" );	
WebSocket.Start( LISTEN_PORT, 64 );	


function Connected( socket, clientID, clientIP, clientPort ){

	if(clientIP != SECURE_IP){
		print( "PHP SDK - Connection from unknown IP " + clientIP + " was blocked");
		socket.Close(clientID);
	}
	SecureConnections[clientID] <- false;
	//Create a timer that will shut the socket 
	//TimeoutTimers[clientID] 	<- NewTimer("TimeoutSocket", 5000, 1, socket, clientID);
}

function ReceiveData( socket, clientID, data ){
	local roottable = getroottable();
	//Only parse any incoming data if the client is identified
	if(SecureConnections[clientID] == true){
		local parsed_data = json_decode( data );
		
		switch(parsed_data["action"]){	
			case "ServerInfo":
				local ServerData = {
					GamemodeName = GetGamemodeName(),
					MapName		 = GetMapName(),
					ServerName	 = GetServerName(),
					MaxPlayers	 = GetMaxPlayers(),
					Players	 	 = GetPlayers(),
					Password	 = GetPassword(),
					Port		 = GetPort(),
					MTUSize		 = GetMTUSize()
				}
				ReturnData( ServerData, socket, clientID );	
				break;
				
			case "CallFunc":
				local paramsArray = [roottable, parsed_data["scriptPath"], parsed_data["funcName"]];
				paramsArray.extend(parsed_data["params"]);
				CallFunc.acall(paramsArray);
				DefaultReturn(socket, clientID);
				break;
				
			case "CallClientFunc":
				local player = FindPlayer(parsed_data["playerID"].tointeger());
				if(player){
					local paramsArray = [roottable, player, parsed_data["scriptPath"], parsed_data["funcName"]];
					paramsArray.extend(parsed_data["params"]);
					CallClientFunc.acall(paramsArray);
					DefaultReturn(socket, clientID);
				}else{
					DefaultReturn(socket, clientID, false);
				}
				break;
				
			case "CurrentPlayers":
				//Loop through the OnlinePlayers array and get their current nickname
				local CurrentPlayers = {};
				foreach(playerID, val in OnlinePlayers ){
					CurrentPlayers[playerID] <- FindPlayer(playerID).Name;
				}
				ReturnData( CurrentPlayers, socket, clientID );	
				break;
			
			//If the action is not preset, check if it is linked to a function on the fly using RegisterWebCallbackFunc()
			default:				
				if(parsed_data["action"] in RegisteredFunctions){
					local returndata = RegisteredFunctions[parsed_data["action"]].call(roottable, parsed_data);
					if( returndata == null ){
						DefaultReturn(socket, clientID, false);
					} else if( returndata == false ) {
						DefaultReturn(socket, clientID, false);
					} else if( returndata == true ) {
						DefaultReturn(socket, clientID, true);
					} else {
						ReturnData( returndata, socket, clientID );
					}
				}else{
					DefaultReturn(socket, clientID, false);
				}
				break;
		}
		//ResetTimeoutTimer(socket, clientID);
		
	//If the client is not identified
	}else{
		//Check if any of their packets contains the SECURE_KEY and identify.
		if(data == SECURE_KEY){
			socket.SendClient("OK\0", clientID);
			SecureConnections[clientID] = true;
		}else{
			print( "PHP SDK - An attempt to identify with an unknown SECURE_KEY was blocked" );
			socket.Close(clientID);
		}
	}
}

//Registers a custom script function to be called externally
function RegisterWebCallbackFunc(action, func){
	RegisteredFunctions[action] <- func;
	return true;
}

//Removes a custom script function to be called, set by RegisterWebCallbackFunc()
function RemoveWebCallbackFunc(action){
	RegisteredFunctions[action] = null;
	return true;
}

//Returns a default JSON success string if a function returns nothing
function DefaultReturn( socket, clientID, successful = true) {
	socket.SendClient(json_encode({success = successful}) + "\0", clientID);
}

//Returns a table of data back to the PHP script
function ReturnData( table, socket, clientID ){
	socket.SendClient( json_encode( table ) + "\0", clientID);
}

//Resets the timeout timer, calls function to close the socket if the timer runs out
function ResetTimeoutTimer( socket, clientID ){
	TimeoutTimers[clientID].Stop();
	TimeoutTimers[clientID].Delete();
	TimeoutTimers[clientID] = null;
	TimeoutTimers[clientID] <- NewTimer("TimeoutSocket", 3000, 1, socket, clientID);
}

//Close the socket
function TimeoutSocket( socket, clientID ){
	socket.Close(clientID);
}

//Supposed to be called by SetLostConnFunc but appears to not work
function Failure( socket, clientID, clientIP, clientPort ){
	print( "PHP SDK - Connection with " + clientIP + " was lost");
}

//Keep track of players for the CurrentPlayers request. 
function onPlayerJoin( player ){
	OnlinePlayers.push( player.ID );
}

function onPlayerPart( player, reason ){
	OnlinePlayers.remove( player.ID );
}



function WebRequest( hostname, port, path, callbackfunc, datatable){
	SendSocket <- NewSocket( "WebResponse" );	
	SendSocket.Connect( hostname, port );
	SendSocket.SetNewConnFunc( "MakeWebRequest" );
	datatable["secureKey"] <- SECURE_KEY;
	WebRequestPath <- path;
	WebRequestData <- postdata_encode(datatable);
	WebRequestCallbackFunction <- callbackfunc;
}

function MakeWebRequest( socket ){
   	SendSocket.Send("POST " + WebRequestPath + " HTTP/1.0\r\n");
    SendSocket.Send("Content-Length: " + WebRequestData.len() + "\r\n");
	SendSocket.Send("Content-Type: application/x-www-form-urlencoded\r\n");
	SendSocket.Send("\r\n");
	SendSocket.Send(WebRequestData);
}

function WebResponse( socket, data ){
	local roottable = getroottable();
	local newline = data.find("\r\n\r\n");
	local headers = data.slice(0, newline);
	local content = json_decode(data.slice(newline + 4, data.len()));
	WebRequestCallbackFunction.call(roottable, content);
}

function onScriptUnload(){
	WebSocket.Stop();
	WebSocket.Delete();
	print( "- Unloaded PHP SDK server -" );
}