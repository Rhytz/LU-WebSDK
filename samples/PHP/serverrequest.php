<?php
	/*
		PHP SDK server for Liberty Unleashed, by Rhytz
		serverrequest.php - Sample file that responds to requests from your LU server
		(c) 2016
	*/
	require_once("lu.class.php");
	
	//The IP of your LU server, to only process requests from that IP.
	$safeIP 		= "123.123.123.123";
	$secureKey 		= "SecureKey123";
	
	
	
	//Returns an array containing request data
	if($request = LU::ReceiveData($safeIP, $secureKey)){
		
		
		
		
		$dataArray = true;
	}else{
		//The request is empty or the SafeIP/Securekey don't match. 
		$dataArray = false;
	}
	

	
	//Return your response to the server. 
	echo LU::Respond($dataArray);
	
?>