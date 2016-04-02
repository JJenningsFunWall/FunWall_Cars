package {
	import flash.events.*;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	import playerio.*;
	import playerio.RoomInfo;
	import fl.motion.Color;
	import flash.geom.ColorTransform;

	public class main extends MovieClip {

		//*** Instance of Main
		public static var instance: main;

		//*** PlayerIO Vars
		private var game_id: String = "cars-q4rejh1gk0quadwhmpitug";
		private var username: String = "user" + Math.random();
		private var playerIndex: int = -1;

		private var roomName: String = "Paris";
		private var roomType: String = "bounce";



		private var playerClient: Client;
		private var playerConnection: Connection;

		//**************************************************
		//***** MAIN FUNCTIONS*************************
		//**************************************************

		public function main() {

			if (main.instance == null) {

				//*** Assign instance
				main.instance = this;
			}

			trace("main initialized");

			//*** Generate Random Char code
			roomName = GenerateRandomCharCode();

			FunWall_Code_Text.text = "FunWall Code: " + roomName;


			//*** Connecting to PlayerIO
			ConnectToPlayerIO();
		}

		public function UpdateLobbyTimerText(pLobbyTimer) {
			LobbyTimer_Text.text = "Game will begin in :" + pLobbyTimer.toString();
		}

		public function ClearLobbyTimer() {

			LobbyTimer_Text.text = "";
		}

		public function UpdateGameTimerText(pGameTimer) {
			GameTimer_Text.text = "Remaining Time In Game : " + pGameTimer.toString();
		}

		public function GenerateRandomCharCode(): String {
			var chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			var num_chars: Number = chars.length - 1;
			var randomChar: String = "";
			var strlen: int = 4;

			//*** Generate Room Code
			for (var i: Number = 0; i < strlen; i++) {
				randomChar += chars.charAt(Math.floor(Math.random() * num_chars)).toUpperCase();
			}

			return randomChar;
		}


		//**************************************************
		//***** PLAYER IO FUNCTIONS*************************
		//**************************************************
		private function ConnectToPlayerIO() {
			trace("Connecting to PlayerIO");

			//*** Connect to PlayIO
			PlayerIO.connect(stage, game_id, "public", username, "", null, handleConnect, handleConnectionError);

			//Username_Label.text = " Connection successful : ";
		}

		private function handleJoinError(error: PlayerIOError): void {
			trace(error);

			//Username_Label.text = " Join Failure : " + error;
		}

		private function handleConnectionError(error: PlayerIOError): void {
			trace(error);

			//Username_Label.text = " Connection Failure : " + error;
		}

		private function handleConnect(client: Client): void {
			trace("Successfully connected to Yahoo Games Network");

			//*** Set Client
			playerClient = client;

			//*** List Rooms
			playerClient.multiplayer.listRooms(roomType, {}, 100, 0, OnListRooms);

			//*** Join Room
			playerClient.multiplayer.createJoinRoom(roomName, roomType, true, {}, {}, onJoin, handleJoinError);
		}


		private function onJoin(connection: Connection): void {
			//Username_Label.text = username + ", ";

			trace("Successfully joined room:", connection.roomId);
			playerConnection = connection;

			/*playerConnection.addMessageHandler("send",
				function (m: Message, message: String): void {
					trace(message);
				});*/

			
				playerConnection.addMessageHandler("SpawnCoin",
				function (m: Message, pCoinID:int ,pCoinXPos:int , pCoinYPos:int): void {
					SpawnCoin(pCoinID,pCoinXPos,pCoinYPos);
				
				});
			
				playerConnection.addMessageHandler("DestroyCoin",
				function (m: Message, pCoinIndex: int): void {
					DestroyCoinsOnStage(pCoinIndex);
				});
				
				
				playerConnection.addMessageHandler("PlayerJoinedRoom",
				function (m: Message, pUserName: String): void {
					
					//*** Call Player Joined Room event
					PlayerJoinedRoom(pUserName); 
				});
				
				playerConnection.addMessageHandler("UpdatePlayerPosition",
				function (m: Message, pUserName: String,pPlayerX:Number, pPlayerY:Number, pPlayerRotation:Number): void {
					
					//*** Call Player Update Position event
					UpdatePlayerPosition(pUserName, pPlayerX , pPlayerY,pPlayerRotation); 
				});

			
		}

		private function OnListRooms(array: Array) {

			for each(var room: RoomInfo in array) {
				// code to display room
				trace(" Player IS Client , room was already created");
				//playerIsHost = false;
			}

			if (array.length == 0) {

				trace(" Player IS Host, no rooms available");
				//playerIsHost = true;
			}


		}
			
		public function SpawnCoin(pCoinID:int,pXpos:int,pYpos:int){
			//trace(" Coin ID:" + pCoinID.toString() + " Coin POS X:" +pXpos.toString() + "Coin Pos Y:"+pYpos.toString());
		}
		
		//*** Event Functions
		public function SpawnCoinInUnity(pCoinID:int, pCoinX:int, pCoinY:int) {
			if (playerConnection) {
				playerConnection.send("SpawnCoin", pCoinID, pCoinX, pCoinY);
			}
		}

		//***********************************
		//*****Event Functions***************
		//***********************************
		public function DestroyCoinsOnStage(pCoinIndex: int) {

			//*** Remove COins on Stage 
			GameController.instance.DestroyCoin(pCoinIndex);
		}

		public function send(message: String): void {
			if (playerConnection) {
				playerConnection.send("send", message);
			}
		}

		public function SendTest(): void {
			if (playerConnection) {
				playerConnection.send("Test", "JJ's Message Recieved!!");
			}
		}
		public function SendAddNewPlayer(pUserName:String , pPlayerIndex:int){
			
			if (playerConnection) {
				
				trace("Adding New Player :" + pUserName);
				playerConnection.send("AddNewPlayer", pUserName,pPlayerIndex);
			}
			
		}
		
		public function PlayerJoinedRoom(pUserName: String) {
				
			trace(" Player: "  + pUserName + " Joined room");
			//*** Create car and name it after player
			GameController.instance.SpawnNewCar(pUserName);
		}
		
		
		
		public function UpdatePlayerPosition(pUserName: String, pPlayerX:Number , pPlayerY:Number, pPlayerRotation:Number) {

			//trace(" Updating Player Position , position == X : " + pPlayerX.toString() + "Y: " + pPlayerY.toString() + " Rotation :"+ pPlayerRotation.toString());
			
			//*** Create car and name it after player
			GameController.instance.UpdatePlayerPositions(pUserName,pPlayerX,pPlayerY,pPlayerRotation);
		}
	}
}