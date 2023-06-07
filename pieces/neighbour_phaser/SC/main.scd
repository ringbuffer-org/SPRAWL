(
{
	p = P2PSC();
	~hostname = Pipe.new("hostname", "r").getLine;
	p.setName(~hostname); // set your name accordingly
	~hostname.post;
	s.sync();

	p.addPath({ |msg|

		// get centroid from message
		var fc = msg[2], wet = 0.5, gain = 0.1;
		var fft, centroid, dry;
		// get local input sound
		var sig  = SoundIn.ar(0);
		dry = 1-wet;
		fc.postln;
		//var sleeptime = 1;
        msg.postln; //print message for debugging



		// calc centroid
		fft = FFT(LocalBuf(2048), sig);
		centroid = SpecCentroid.kr(fft);

		// mix dry/wet filtered sound
		{Out.ar(0, (BPF.ar(sig, fc.lag(0.1))*wet + sig*dry) * gain)}.play;

        fork {
            var nextpeer;
            var source_peer = msg[1].asString;
            var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
            //sleeptime.wait; // wait for one second

            // send to the next peer in our list
            nextpeer = peers.wrapAt(1+peers.indexOfEqual(source_peer));
            p.sendMsg("/"++nextpeer++"/ping", p.name, centroid.asString)
            };

        },"/ping"
        );
    }.fork;
)
// ~stream.set(\cf, 1000) // setter by reference

