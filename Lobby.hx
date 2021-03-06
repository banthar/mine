
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;

import flash.net.NetConnection;
import flash.net.NetStream;
import flash.events.NetStatusEvent;

import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;

import flash.filters.BlurFilter;

class Lobby extends Frame
{

	var background:Bitmap;

	var stratus:NetConnection;

	var server:NetStream;
	var serverReady:Bool;
	
	var client:NetStream;
	var clientReady:Bool;
	
	var myId:Int;
	
	var game_class:Class<Game>;
	var game:Game;
	
	var wantsRestart:Bool;
	
	public function new(game_class:Class<Game>)
	{
		
		super();
		
		background=new Bitmap();
		background.z=-1.0;
		addChild(background);		
		
		this.game_class=game_class;
		
		trace("Connectiong to stratus");
		
		stratus = new NetConnection();
		stratus.addEventListener(NetStatusEvent.NET_STATUS,stratusStatus);
		stratus.connect("rtmfp://stratus.adobe.com/dbf9a8283db8e9234f849c03-10c857f3944b");
	
		reset();

		drawConnecting();


	}

	private function stratusStatus(event:NetStatusEvent)
	{

		trace("stratusStatus: "+event.info.code);

		switch(event.info.code)
		{
			
			case "NetConnection.Connect.Success":
				trace("Sucesfully connected to stratus");
				listen();
			case "NetStream.Connect.Success":
				trace("stratusStatus NetStream.Connect.Success");
			case "NetStream.Connect.Closed":
				if(event.info.stream == server || event.info.stream == client)
				{
					reset();
					drawEnterID("Connection terminated");
				}
			default:
				trace("unknown stratusStatus: "+event.info.code);
		}

	}

	private function listen()
	{
		
		if(server!=null)
			throw "double listen";
		
		server = new NetStream(stratus,NetStream.DIRECT_CONNECTIONS);
		server.addEventListener(NetStatusEvent.NET_STATUS, serverStatus);
		server.publish("main");
		
		server.client={};
		server.client.onPeerConnect=onPeerConnect;
	}

	private function onPeerConnect(callerns:NetStream)
	{
		trace("onPeerConnect");
		
		if(serverReady)
		{
			trace("dropping late peer "+callerns.farID);
			return false;
		}
		
		serverReady=true;
		
		if(client==null)
		{
			
			myId=1;
			
			trace("creating return connection");
			connect(callerns.farID);
		}
		
		return true;
		
	}

	private function serverStatus(event:NetStatusEvent)
	{
		
		trace("serverStatus: "+event.info.code);
		
		switch(event.info.code)
		{
			case "NetStream.Publish.Start":
				trace("outputStream published");
				trace("peers can now connect to: "+stratus.nearID);
				drawEnterID();
			case "NetStream.Play.Start":
				trace("client connected");
				if(serverReady && clientReady)
					startGame();
			default:
				trace("unknown outputStatus: "+event.info.code);
		}
	}

	public function connect(farID:String)
	{
		if(client!=null)
			throw "double connect";
			
		trace("connecting to: "+farID);
		
		client = new NetStream(stratus,farID);
		client.addEventListener(NetStatusEvent.NET_STATUS,clientStatus);
		client.play("main");

		client.client={};
			
	}

	private function clientStatus(event:NetStatusEvent)
	{

		trace("clientStatus: "+event.info.code);

		switch(event.info.code)
		{
			case "NetStream.Play.Start":
				trace("client Play");
				clientReady=true;
				if(serverReady && clientReady)
					startGame();
			case "NetStream.Play.Failed":
				reset();
				drawEnterID("Connection terminated");
			default:
				trace("unknown clientStatus: "+event.info.code);
		}
	}

	private function startGame(?_)
	{
		trace("startGame "+myId);
		
		clear();
		
		game=Type.createInstance(game_class,[client,server,myId]);
		
		game.onGameOver=onGameOver;
		
		addChild(game.getDisplayObject());
	}

	private function onGameOver(winner:Bool)
	{
		
		var t=this;
		
		updateBackground();
		
		if(game!=null)
		{
			removeChild(game.getDisplayObject());
			game.destroy();
			game=null;
		}
		
		clear();
		
		if(winner)
		{
			addLabel("Congratulations!",24);
			addLabel("You found all the mines",16);
		}
		else
		{
			addLabel("Game Over",24);
		}

		addLabel("\n",24);
		
		wantsRestart=false;
		
		addButton("Restart",24,onRestart);


		client.client.restart=restart;
		client.client.disconnect=disconnect;

		addButton("Disconnect",24,function(_){t.server.send("disconnect");t.disconnect();});
		
		organise();
		
	}

	private function onRestart(_)
	{
		disableLabel(cast(getChildByName("Restart")));
		server.send("restart");
		restart();
		
	}

	private function restart()
	{
		
		if(wantsRestart)
			startGame();
		else
			wantsRestart=true;
		
	}

	private function disconnect()
	{
		reset();
		drawEnterID();
	}

// UI

	private function disableLabel(label:Sprite)
	{
		label.mouseEnabled=false;
		label.alpha=0.2;
	}

	private function drawConnecting()
	{
		
		clear();

		addLabel("Connecting ...",24);

		organise();

		
	}
	
	var remoteIdlabel:TextField;

	private function drawEnterID(?message:String)
	{
	
		clear();

		if(message!=null)
		{
			var label=addLabel(message+"\n",24);
			label.textColor=0xff0000;
		}

		addLabel("Your ID:",24);
		var idLabel=addLabel(stratus.nearID,16);


		addLabel("\nRemote ID:",24);
		
		remoteIdlabel=addLabel("",16);
		remoteIdlabel.border=true;
		remoteIdlabel.autoSize=flash.text.TextFieldAutoSize.NONE;
		remoteIdlabel.type = TextFieldType.INPUT;
		remoteIdlabel.width=idLabel.width;
		remoteIdlabel.height=idLabel.height;
		remoteIdlabel.maxChars=idLabel.text.length;

		addLabel("\n",24);

		
		addButton("Connect",24,onConnectPress);
		
		organise();
		
	}

	private function onConnectPress(_)
	{
		
		if(remoteIdlabel.text == "" || remoteIdlabel.text == stratus.nearID)
		{
			return;
		}
		
		connect(remoteIdlabel.text);
		
		drawConnecting();
		
	}

	private function reset(?_)
	{
		
		myId=0;
		
		if(game!=null)
		{
			removeChild(game.getDisplayObject());
			game.destroy();
			game=null;
		}
		
		serverReady=false;
		clientReady=false;
		
		if(client!=null)
		{
			client.close();
			client.removeEventListener(NetStatusEvent.NET_STATUS,clientStatus);
			client=null;
		}
		
		if(server!=null)
		{
//			server.close();
//			server.client={};
//			server.client.onPeerConnect=onPeerConnect;
		}
	}

	public function updateBackground()
	{
		
		var bitmap=new BitmapData(Std.int(Main.stage.stageWidth),Std.int(Main.stage.stageHeight));

		bitmap.draw(Main.stage);
		
		bitmap.applyFilter(bitmap,bitmap.rect, new Point(0,0), new BlurFilter());
		bitmap.colorTransform(bitmap.rect, new ColorTransform(0.25,0.25,0.25,1.0,168,168,168,0));

		background.bitmapData=bitmap;
		
	}

	override public function clear()
	{
		super.clear();
		addChild(background);
	}

}

