
import flash.display.Sprite;

import flash.net.NetConnection;
import flash.net.NetStream;
import flash.events.NetStatusEvent;

import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.geom.Rectangle;

class Lobby extends Sprite
{

	var stratus:NetConnection;

	var server:NetStream;
	var serverReady:Bool;
	
	var client:NetStream;
	var clientReady:Bool;
	
	var myId:Int;
	
	var game_class:Class<Game>;
	var game:Game;
	
	public function new(game_class:Class<Game>)
	{
		
		super();
		
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
				if(event.info.stream != server && event.info.stream != client)
				{
					trace("unknown");
				}
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

	private function onGameOver()
	{
		if(game!=null)
		{
			removeChild(game.getDisplayObject());
			game.destroy();
			game=null;
		}
		
		clear();
		
		addLabel("Game Over",24);

		addLabel("\n",24);
		
		addLabel("Restart",24,startGame);

		var t=this;

		addLabel("Disconnect",24,function(_){t.reset();t.drawEnterID();});
		
		organise();
		
	}

// UI

	private function clear()
	{
		
		graphics.clear();
		
		while(numChildren>0)
		{
			removeChildAt(numChildren-1);
		}
	}

	private function addLabel(text:String,size:Float,?c:Dynamic->Void)
	{
		var text_field=new TextField();
		text_field.defaultTextFormat=new TextFormat("Arial",size);
		text_field.text=text;
		text_field.autoSize=flash.text.TextFieldAutoSize.CENTER;

		if(c!=null)
		{
			
			var s=new Sprite();
			
			s.mouseChildren=false;
			s.buttonMode=true;
			
			s.addChild(text_field);
			addChild(s);
			
			s.addEventListener(MouseEvent.CLICK,c);
			
		}
		else
		{
			addChild(text_field);
		}
		
		return text_field;
		
	}


	private function organise()
	{
		var h=0.0;
		
		for(i in 0...numChildren)
		{
			h+=4;
			h+=getChildAt(i).height;
		}
		
		var ypos=(Main.stage.stageHeight-h)/2.0;
		
		for(i in 0...numChildren)
		{
			var c=getChildAt(i);
			
			c.x=(Main.stage.stageWidth-c.width)/2;
			c.y=ypos;
			ypos+=c.height+4;
			
		}
		
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

		
		addLabel("Connect",24,onConnectPress);
		
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

}

