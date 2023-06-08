

s.waitForBoot(
    {
		p = P2PSC();
		~hostname = Pipe.new("hostname", "r").getLine;
		p.setName(~hostname); // set your name accordingly
		~hostname.post;
		s.sync();

		p.addPath({ |msg|
			var gain = msg[2].asFloat;
			var sleeptime = msg[3].asFloat;
			// var freq = msg[4].asFloat;
            var freq = 100 + 1000.rand; // Change this for every node
            msg.postln; //print message for debugging

            {SinOsc.ar(freq:freq)*gain*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
            fork {
                var nextpeer;
                var source_peer = msg[1].asString;
                var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
				var new_gain = gain * 0.8;
				if(new_gain > 0.05){
					sleeptime.wait;

					// send to the next peer in our list
					nextpeer = peers.wrapAt(1+peers.indexOfEqual(source_peer));
					p.sendMsg("/"++nextpeer++"/ping", p.name, new_gain, sleeptime, freq)
				}

            };

        },"/ping"
        );
    }.fork;
);
