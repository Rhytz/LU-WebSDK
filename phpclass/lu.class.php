<?php
	/*
		PHP SDK server for Liberty Unleashed, by Rhytz
		lu.class.php - PHP class for communicating with the LU server
		(c) 2016
	*/

	class LU
	{
		protected $socket;
	
		public function __construct($ip, $port, $key) {
			$this->socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
			if(!$this->socket){
				throw new Exception("LU class error - Could not create socket - ". socket_strerror(socket_last_error()));
			}
			
			$result = @socket_connect($this->socket, $ip, $port);
			if(!$result){
				throw new Exception("LU class error - Could not connect - ". socket_strerror(socket_last_error()));
			}
			
			socket_write($this->socket, $key, strlen($key));
			while ($out = socket_read($this->socket, 2048)) {
				if($out !== "OK"){
					throw new Exception("LU class error - Secure key invalid");
				}else{
					return true;
				}				
			}
			
		}
		
		function __destruct() {
			socket_close($this->socket);
			unset($this->socket);
		}	
		
		public static function ReceiveData($safeIP = false, $secureKey = false) {
			global $_POST;
			$request 	= $_POST;
			$serverIP 	= $_SERVER['REMOTE_ADDR'];

			
			if($safeIP && $serverIP != $safeIP){
				return false;
			}
			
			if($secureKey && !isset($request['secureKey']) || $secureKey != $request['secureKey']){
				return false;
			}
			
			return $request;
		}
		
		public static function Respond($data = false){
			if(is_array($data)){
				return json_encode($data, JSON_UNESCAPED_SLASHES);
			}elseif($data){
				$status = array("success" => true);
				return json_encode($status, JSON_UNESCAPED_SLASHES);			
			}else{
				$status = array("success" => false);
				return json_encode($status, JSON_UNESCAPED_SLASHES);				
			}
		}

		public function SendData($data){
			$data = json_encode($data, JSON_UNESCAPED_SLASHES);
			socket_write($this->socket, $data, strlen($data));
			while ($out = socket_read($this->socket, 2048)) {
				return json_decode($out);
			}
			
		}		
		
		public function CallFunc($scriptPath, $funcName, $params = array()){
			$data = array(
				'action' 		=> 'CallFunc',
				'scriptPath' 	=> $scriptPath,
				'funcName' 		=> $funcName,
				'params'		=> $params
			);
			return $this->SendData($data);
		}
		
		public function CallClientFunc($playerID, $scriptPath, $funcName, $params = array()){
			$data = array(
				'action' 		=> 'CallClientFunc',
				'playerID' 		=> $playerID,
				'scriptPath' 	=> $scriptPath,
				'funcName' 		=> $funcName,
				'params'		=> $params
			);
			return $this->SendData($data);		
		}
		
		//Calls a function that was defined on the server using RegisterWebCallbackFunc(), but doesn't have its own PHP function
		public function CallRegisteredFunc($action, $params = array()){
			$data = array(
				'action' 		=> $action,
				'params'		=> $params
			);			
		}
		
		public function ServerInfo(){
			$data = array(
				'action' 		=> 'ServerInfo',
			);
			return $this->SendData($data);
		}
		
		public function CurrentPlayers(){
			$data = array(
				'action' 		=> 'CurrentPlayers',
			);
			return $this->SendData($data);
		}
	}
?>