<?php
	/*
		PHP SDK server for Liberty Unleashed, by Rhytz
		sample.php - Sample file shows how to extend the class with your own functions and make calls to the server
		(c) 2016
	*/

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
		
		public function SetWeather($id){
			$data = array(
				'action' 		=> 'SetWeather',
				'id'			=> $id
			);	
			return $this->SendData($data);
		}
		
		//Returns player cash or sets it to any supplied value
		public function Cash($playerID, $value = false){
			$data = array(
				'action' 		=> 'Cash',
				'playerID'		=> $playerID,
				'value'			=> $value
			);	
			return $this->SendData($data);		
		}
		
		//A Squirrel function linked to action "testfunction" on the LU server using RegisterWebCallbackFunc(action, function)
		public function TestFunction(){	
			$data = array(
				'action' 		=> 'testfunction'
			);	
			return $this->SendData($data);				
		}		
	}
	
	
	
	//Using the class
	
	//Connect to the server
	$MyLUserver = new MyLUserver("123.123.123.123", 2302, "SecureKey123");
	
	//Set the weather to "Cloudy" (id 1)
	$MyLUserver->SetWeather(1);
	
	//Associative array linking weather ID's to weather name
	$weatherIDs = array(
		0 => "Sunny",
		1 => "Cloudy",
		2 => "Rainy",
		3 => "Foggy"
	);
	
	//Return the current weather in the server 
	echo "The weather in my Liberty Unleashed server is currently: ". $weatherIDs[$MyLUserver->GetWeather()->WeatherID];
	
	//Loop through all the players in the server and give them $100000
	foreach($MyLUserver->CurrentPlayers() as $playerID => $playerName){
		$MyLUserver->Cash($playerID, 100000);
		echo "Given $100000 to " . $playerName . "<br />";
	}
	
?>
