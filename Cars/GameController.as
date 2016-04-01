package  {
	
	import flash.events.*;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	import playerio.*;
	import playerio.RoomInfo;
	import fl.motion.Color;
	import flash.geom.ColorTransform;
	import flash.display.DisplayObject;
	
	
	public class GameController extends MovieClip {
		
		public static var instance:GameController;
		
		private var gameUpdateTimer: Timer;
		private var lobbyWaitingTimer: Timer;	
		private var coinSpawnTimer: Timer;	
		
		public var defaultLobbyWaitTime:int = 20;
		public var defaultGameWaitTime:int = 120;
		public var defaultCoinSpawnTime:int = 120;
		
		
		public var lobbyTimer:int = 30;
		public var gameTimer:int = 120;
		
		public var playerCar:Car;

		private var coinContainer:MovieClip;
		private var carContainer:MovieClip;
		
		private var containerScalerValue:Number = 1.5;
		
		//*** coinID
		public var coinID:int = 0;
		
		//*** coin Instances
		public var player_Objects: Array = new Array();
		public var coin_Objects: Array = new Array();
		
		public function GameController() {
			// constructor code

			//*** Create ccoinContainer
			coinContainer = new MovieClip();
			carContainer = new MovieClip();
			
			var oCoinScaleValue:Number = 1;
			var oCarScaleValue:Number = 1;
			
			oCoinScaleValue = coinContainer.scaleX * containerScalerValue;
			
			coinContainer.scaleX = oCoinScaleValue;
			coinContainer.scaleY = oCoinScaleValue;
			
			oCarScaleValue = carContainer.scaleX * containerScalerValue;
			
			carContainer.scaleX = oCarScaleValue;
			carContainer.scaleY = oCarScaleValue;
			
			//*** SEt Contianer in center
			coinContainer.x = 0;
			coinContainer.y = 0;
			
			
			//trace(" Car Container X: " + carContainer.x.toString() + " Car Container Y : " + carContainer.y.toString());
			
			this.addChild(coinContainer);
			this.addChild(carContainer);
			
			if(instance == null){
				
				//*** Assign instance
				instance = this;
				
				trace("Game Controller Initialized");
			}
			
			//*** We're waiting for players to join 
			WaitForPlayersToJoin();
		}
		
		public function WaitForPlayersToJoin(){
			
			//*** Set Timers
			lobbyTimer = defaultLobbyWaitTime;
			gameTimer = defaultGameWaitTime;
			
			
			//*** Create Lobby Timer
			lobbyWaitingTimer = new Timer(1000,defaultLobbyWaitTime);
			lobbyWaitingTimer.addEventListener(TimerEvent.TIMER,UpdateLobbyTimer);
			lobbyWaitingTimer.start();
			
			
		}
		
		
		public function StartMatch(){
			
			//*** Clear Loby Timer
			main.instance.ClearLobbyTimer();
			
			//*** Timer Related to game
			gameUpdateTimer = new Timer(1000,defaultGameWaitTime);
			gameUpdateTimer.addEventListener(TimerEvent.TIMER,UpdateGameTimer);
			gameUpdateTimer.addEventListener(TimerEvent.TIMER_COMPLETE,EndMatch);
			gameUpdateTimer.start();
			
			//*** Establish coin spawn timer
			coinSpawnTimer = new Timer(3000,defaultCoinSpawnTime);
			coinSpawnTimer.addEventListener(TimerEvent.TIMER,SpawnNewCoin);
			coinSpawnTimer.start();
			
		}
		public function EndMatch(evt: TimerEvent = null){
			
			
			trace("Game Is Over");
		}
		
		
		
		public function SpawnNewCoin(evt: TimerEvent = null){
			
			//*** Create new coin and add it to the stage
			var newCoin:coin = new coin();
			newCoin.SetCoinID(coinID);
			newCoin.name = "Coin" + coinID.toString();
			
			coinContainer.addChild(newCoin);
			
			//*** Set Position
			newCoin.x = Math.random()*300;
			newCoin.y = Math.random()*300;
			
			//*** Add coins to list
			coin_Objects.push(newCoin);
			
			//*** Spawn Coin 
			main.instance.SpawnCoinInUnity(coinID,newCoin.x,newCoin.y);
			
			//*** Increment Coin ID value
			coinID++;
			
			//*** Destroy coin
			//DestroyCoin(newCoin.name);
		}
		
		public function DestroyCoin(pCoinIndex:int){
			
			//*** tempcoin value
			var tempCoin:DisplayObject ;
			
			
			tempCoin = coinContainer.getChildByName("Coin"+pCoinIndex.toString());
			
				if(tempCoin != null){
					
				
					//*** Remove Child object
					coinContainer.removeChild(tempCoin);
					
					trace(" Destroyed Coin");
				}
			
			
		}
		
		public function SpawnNewCar( pPlayerName:String){
			
			//*** Create new coin and add it to the stage
			playerCar = new Car();
			carContainer.addChild(playerCar);
			playerCar.name = pPlayerName;
			
			//trace("player Cap Init Position == X:" + playerCar.x.toString() + " Y:" + playerCar.y.toString());
			
			//*** Add car to array
			player_Objects.push(playerCar);
			
			//*** Add New players
			AddNewPlayers();
		}
		
		public function AddNewPlayers(){
			
			//*** Iterator
			var i:int;
			var oCar:DisplayObject;
			
			for(i = 0 ; i < carContainer.numChildren ; i++){
				
				//*** assign care
				oCar = carContainer.getChildAt(i);
				
				if(oCar != null){
					//*** ADD Players
					main.instance.SendAddNewPlayer(oCar.name);
					trace(" Car name == " +oCar.name);
					
				}
			}
			
			
		}
		
		public function UpdatePlayerPositions( pUserName:String, pPlayerX:int, pPlayerY:int, pPlayerRotation:int){
			
			//*** Declare Iterator
			//var i:int = 0;
			//var car:Car;
			
			//for(i = 0 ; i < player_Objects.count ; i++){
				
				//*** Get Car
				//car = player_Objects[i];
				
				//if(car.name == pUserName){
					
					//*** Assign Car positions
					//playerCar.x = pPlayerX + 512;
					//playerCar.y = (pPlayerY * -1) + 359;
					//playerCar.rotation = pPlayerRotation;
					
				//}
				
			//}
			
			
			//*** Test Multiplayer shiz
			
			
			//*** Declare Iterator
			var i:int = -1;
			var car:DisplayObject = null;
			
			//*** Get Car Object
			car = carContainer.getChildByName(pUserName);
			
			if(car!= null){
			//for(i = 0 ; i < player_Objects.count ; i++){
				
				//*** Get Car
				//car = player_Objects[i];
				
				//if(car.name == pUserName){
					
					//*** Assign Car positions
					car.x = pPlayerX + 512;
					car.y = (pPlayerY * -1) + 359;
					car.rotation = pPlayerRotation;
			}
			
			
			
			
		}
		
		public function UpdatePlayerPositions2( pUserName:String, pPlayerX:int, pPlayerY:int, pPlayerRotation:int){
			
			//*** Declare Iterator
			var i:int = -1;
			var car:Car = null;
			
			//*** Get Car Object
			//car = carContainer.getChildByName(pUserName);
			
			if(car!= null){
			//for(i = 0 ; i < player_Objects.count ; i++){
				
				//*** Get Car
				//car = player_Objects[i];
				
				//if(car.name == pUserName){
					
					//*** Assign Car positions
					car.x = pPlayerX + 512;
					car.y = (pPlayerY * -1) + 359;
					car.rotation = pPlayerRotation;
			}
				//}
				
			//}
			
		}
		
		
		//*** Timer Functions
		
		private function UpdateLobbyTimer(evt: TimerEvent): void {
			
			//*** Set Lobby timer Text
			//LobbyTimer_Text.text = "Game will begin in :" +lobbyTimer.toString();
			//trace("Lobby Timer == " + lobbyTimer.toString());
			if(lobbyTimer > 0){
				//*** Decrement timer
				lobbyTimer--;
			}
			
			if(main.instance != null){
			
				//*** Send Value to main class
				main.instance.UpdateLobbyTimerText(lobbyTimer);
			}
			if(lobbyTimer == 0){
				
				StartMatch();
			}
			
		}
		
		private function UpdateGameTimer(evt: TimerEvent): void {
			
			//*** Decrement timer
			gameTimer--;
			
			if(main.instance != null){
				//*** Send Value to main class
				main.instance.UpdateGameTimerText(gameTimer);
				
			}
		}
	}
	
}
