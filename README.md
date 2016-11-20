# Liberty Unleashed WebSDK
The Liberty Unleashed WebSDK allows you to interface with your Liberty Unleashed server over the web. You can make GET/POST requests to your website from your LU server, but also query your server from the web in real time. 

### Installation - Squirrel script
Modify the constants in websdk.nut to suit your needs, and include it in your script like so:

```Squirrel
function onScriptLoad(){
	dofile("Scripts/Path/To/File/websdk.nut");
}
```

### Usage - Making requests from your LU server
To make a request to your website, use the function WebRequest().
```Squirrel
    WebRequest( Domain/Hostname, Port, Path, CallBackFunction, DataToSend );
```
Sample usage:
```Squirrel
    DataToSend <- { "ping" : "ping" };
    WebRequest("mydomain.com", 80, "/serverrequest.php", CallBackFunction, DataToSend );
```
When the webserver responds, the defined callback function will be called with a Data parameter, containing a table with the response. The expected response from the webserver is a completely empty page containing just JSON data.
```Squirrel
function CallBackFunction(data){
	print(data["pong"]);
}
```
### Usage - Handling the request on your webserver
Because communication happens through JSON, you are not just limited to using PHP on the webserver side. With these examples we will however focus on the included PHP class. 
```php
	require_once("lu.class.php");
	
	//The IP of your LU server, to only process requests from that IP.
	$safeIP 		= "123.123.123.123";
	$secureKey 		= "SecureKey123";
	
	//Returns an array containing request data
	if($request = LU::ReceiveData($safeIP, $secureKey)){
		$dataArray = array("pong" => "pong");
	}else{
		//The request is empty or the SafeIP/Securekey don't match. 
		$dataArray = false;
	}

	//Return your response to the server. 
	echo LU::Respond($dataArray);
``` 
### Usage - Making requests from your webserver
Using the PHP class you can query your LU server in realtime and return data from it. The class has some basic requests already built in, but you can extend it with your own functions.
```php
	require_once("lu.class.php");
	
	//Extend the LU class with your own custom functions
	class MyLUserver Extends LU{
		//Some sample functions
		public function GetWeather(){
			$data = array(
				'action' 		=> 'GetWeather',
			);	
			return $this->SendData($data);
		}
	}
	//Using the class
	
	//Connect to the server
	$MyLUserver = new MyLUserver("123.123.123.123", 2302, "SecureKey123");
	
	//Associative array linking weather ID's to weather name
	$weatherIDs = array(
		0 => "Sunny",
		1 => "Cloudy",
		2 => "Rainy",
		3 => "Foggy"
	);
	
	//Return the current weather in the server 
	echo "The weather in my Liberty Unleashed server is currently: ". $weatherIDs[$MyLUserver->GetWeather()->WeatherID];
```

### Usage - Handling the request on your LU server
You can register functions to be called from your website in real time using RegisterWebCallbackFunc(). 
```Squirrel
RegisterWebCallbackFunc( Action, CallBackFunction )
```
Sample usage
```Squirrel
RegisterWebCallbackFunc("GetWeather", Web_GetWeather);
```
This will call the Web_GetWeather() when your LU server receives a request from your webserver, and the "action" parameter is set to GetWeather. Getweather() will be called with a Data parameter containing a table with additional data.
```Squirrel
function Web_GetWeather(data){
	local Weather = {
		WeatherID = GetWeather()
	}
	return Weather;
}
```
Using "return" you can either return a table, or true/false back to the webserver. In this case we return a table containing the Weather ID. 

### Built-in functions
The Squirrel script already has some basic functions built in which you can call from your webserver. These functions are also predefined in the PHP class.

#### ServerInfo
Returns info about the server
PHP: 
```php
$MyLUserver->ServerInfo();
```
Raw JSON data being sent:
```json
{"action":"ServerInfo"}
```
Expected JSON Response:
```json
{"MTUSize": 576,"MapName":"Liberty City","Players": 0,"GamemodeName":"Deathmatch","Port": 2301,"MaxPlayers": 128,"Password":"123welkom!","ServerName":"Rhytz's Scripting test server"}
```

#### CallFunc
Calls a function in another script file on the LU server.

PHP:
```php
$MyLUserver->CallFunc( $path, $funcName, $params[] );
```
Raw JSON data being sent:
```json
{"action":"CallFunc","scriptPath":"path/to/script.nut","funcName":"FunctionToCall","params":["value1","value2"]}
```
Expected JSON Response:
```json
{"success": true}
``` 

#### CallClientFunc
Calls a function in a script file on the client

PHP:
```php
$MyLUserver->CallClientFunc( $playerID, $path, $funcName, $params[] );
```
Raw JSON data being sent:
```json
{"action":"CallClientFunc","playerID":0,"scriptPath":"path/to/script.nut","funcName":"FunctionToCall","params":["value1","value2"]}
```
Expected JSON Response:
```json
{"success": true}
``` 

#### CurrentPlayers
Returns an associative array containing a list of online players.

PHP:
```php
$MyLUserver->CurrentPlayers();
```
Raw JSON data being sent:
```json
{"action":"CurrentPlayers"}
```
Expected JSON Response:
```json
{"0":"Rhytz"}
``` 

#### CallRegisteredFunc
Calls a function on the LU server that is registered using RegisterWebCallbackFunc()

PHP:
```php
$MyLUserver->CallRegisteredFunc( $action, $params[] );
```
Raw JSON data being sent:
```json
{"action":"callAFunction","params":{"param1":"value1","param2":"value2"}}
```
JSON response depends on registered function

## Todo
- Make the Squirrel script into a class. This however seems impossible because of the way LU registers callback functions for the sockets
