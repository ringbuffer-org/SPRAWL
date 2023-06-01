

s.waitForBoot(
    {
		p = P2PSC();
		~hostname = Pipe.new("hostname", "r").getLine;
		p.setName(~hostname); // set your name accordingly
		~hostname.post;
		s.sync();

		p.addPath({ |msg|

			var sleeptime = 1;
            var freq = 100 + 1000.rand; // Change this for every node
            msg.postln; //print message for debugging

            {SinOsc.ar(freq:freq)*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
            fork {
                var nextpeer;
                var source_peer = msg[1].asString;
                var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
                sleeptime.wait; // wait for one second

                // send to the next peer in our list
                nextpeer = peers.wrapAt(1+peers.indexOfEqual(source_peer));

                p.sendMsg("/"++nextpeer++"/ping", p.name)
            };

        },"/ping"
        );
    }.fork;
);

