(
s.waitForBoot(
{
	p = P2PSC();
	// get own hostname and set it
	~hostname = Pipe.new("hostname", "r").getLine;
	p.setName(~hostname);
	// print hostname to console
	~hostname.post;
	// sync node
	p.sync();
	ps = p.getPeers().select({ |item| item.beginsWith("AP") });
	ps.postln;
	b = bus.control(s(1));

	// local sound player, streams I to O with dry/wet bandpass
	~stream = { arg fc = 1000; // center freq of bandpass
		var wet = 0.8, gain = 0.2, sig = SoundIn.ar(0);
		Out.ar(0, (BPF.ar(sig, fc.lag(0.1))*wet + sig*(1-wet)) * gain)
	}.play;

	~sender = {
		// get list of all peers
		var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
		// define next peer and self
		var nextpeer;
		// send to the next peer in our list
		nextpeer = peers.wrapAt(1+peers.indexOfEqual(p.name));
		// send message to next peer with "np" identifier and the centroid
		p.sendMsg("/"++nextpeer++"/np", In.kr(b).asString)
	}.play;

	~feature = {
		// declare centroid vars
		var fft, centroid;
		// get fft from local input
		fft = FFT(LocalBuf(2048), SoundIn.ar(0));
		// calc spectral centroid
		centroid = SpecCentroid.kr(fft);
		Out.kr(b, centroid);

		//sleeptime.wait;
		
	}.play;

		// see https://github.com/ringbuffer-org/SPRAWL/blob/main/pieces/Delay_Graph/SC/delay_gui.scd

	// define P2PSC listener (listens to "/np" channel)
	p.addPath({arg msg;
		// change center freq of audio
		~stream.set(\fc, msg[1].sFloat);
		}, "/np");
    };
);
)

// (
// local sound routine, streams I to O with dry/wet bandpass
// ~stream = { arg fc = 1000; // center freq of bandpass
// 	var wet = 0.5, gain = 0.8, sig = SoundIn.ar(0);
// 	// Out.ar(0, sig * gain);
// 	Out.ar(0, (BPF.ar(sig, fc.lag(0.1))*wet + sig*(1-wet)) * gain)
// }.play;
// )

// { [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;