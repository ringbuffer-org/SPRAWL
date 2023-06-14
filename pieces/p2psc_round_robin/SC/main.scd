
s.waitForBoot(
    {
		p = P2PSC();
		~hostname = Pipe.new("hostname", "r").getLine;
		p.setName(~hostname); // set your name accordingly
		~hostname.post;
		s.sync();
		Routine(
		{{

			~window = Window(bounds:800@480).front().background_(Color.black);

			~window.fullScreen;


			~button = Button(~window, Rect(100, 100, 600, 280));

			~button.states = [["FIRE", Color.black, Color.red]];


			~button.action_({
				fork{
				var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
				var nextpeer = peers.wrapAt(peers.size.rand);
				p.sendMsg("/"++nextpeer++"/ping", 1.0, 1.0.rand, 100+1000.rand);
					}

			});

			~window.front;

		}.defer;}
		).play;

		p.addPath({ |msg|
			var gain = msg[1].asFloat;
			var sleeptime = msg[2].asFloat;
			 var freq = msg[3].asFloat;
            //var freq = 100 + 1000.rand; // Change this for every node
            msg.postln; //print message for debugging

            {SinOsc.ar(freq:freq)*gain*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
            fork {
                var nextpeer;
                var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
				var new_gain = gain * 0.7;
				if(new_gain > 0.05){
					sleeptime.wait;

					// send to the next peer in our list
					nextpeer = peers.wrapAt(peers.size.rand);
					p.sendMsg("/"++nextpeer++"/ping", new_gain, sleeptime, freq + 5.rand2)
				}

            };

        },"/ping"
        );
    }.fork;
);

