(
var window;
var slider;
var button;

var lastxValue = 0.5;
var lastyValue = 0.5;

var oscOutPort = NetAddr("192.168.14.172",69420);
var oscInPort = NetAddr("192.168.14.172",69420);

var isMouseDown = false;

thisProcess.openUDPPort(69420);
s.waitForBoot(
    Routine({
        "Starting Democratic Soundscapes Setup".postln;
        {
			window = Window("Client", Rect(100,100, 440 ,440));
			window.front;

			slider = Slider2D(window, Rect(20, 20, 400, 400))
			.x_(0.5).y_(1);

			button = UserView(window, Rect(20, 20, 20, 20));
			button.background = Color.green;

			slider.mouseDownAction = { arg view,x,y,pressure,tiltx,tilty,deviceID, buttonNumber,clickCount;
				isMouseDown = true;
			};

			slider.mouseUpAction = { arg view,x,y,pressure,tiltx,tilty,deviceID, buttonNumber,clickCount;
				isMouseDown = false;
			};

			AppClock.sched(0.3, {
				if (isMouseDown, { oscOutPort.sendMsg("/vote/ID/x", slider.x); oscOutPort.sendMsg("/vote/ID/y", slider.y);},{ nil });

				button.moveTo(20 + (lastxValue * 380), 20 + (((lastyValue * -1)+
					1)* 380)); //GO FROM 20 to 400
				0.3;
			});


			~osc_receive = OSCFunc(

				{ arg msg, time, addr, recvPort;
					lastxValue = msg[1];
			}, '/voteResult/x');

			~osc_receive = OSCFunc(

				{ arg msg, time, addr, recvPort;
					lastyValue = msg[1];
			}, '/voteResult/y');

			window.onClose = {
				AppClock.clear;
			};


			slider.setProperty(\clipInBounds,0);
			button.alwaysOnTop = true;
			window.front;
			NetAddr.localAddr.postln;
        }.defer;
    });
    , onFailure: {"[ERROR] failed to start the main routine".postln});
)