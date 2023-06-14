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
	"test".postln;
	p.getPeers().select({ |item| item.beginsWith("AP") }).postln;

	// define P2PSC communication routine
	p.addPath({arg msg;
		// declare centroid vars
		var fft, centroid;
		// define next peer and self
		var nextpeer, source_peer = msg[1].asString;
		// get list of all peers
		var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
		// debug message
		msg.postln;

		// local sound routine, streams I to O with dry/wet bandpass
		~stream = { arg fc = 1000; // center freq of bandpass
			var wet = 0.8, gain = 0.2, sig = SoundIn.ar(0);
			Out.ar(0, (BPF.ar(sig, fc.lag(0.1))*wet + sig*(1-wet)) * gain)
		}.play;

		// change center freq of audio routine
		~stream.set(\fc, msg[2]);

		// get fft from local input
		fft = FFT(LocalBuf(2048), SoundIn.ar(0));
		// calc spectral centroid
		centroid = SpecCentroid.kr(fft);

		//sleeptime.wait;
		// send to the next peer in our list
		nextpeer = peers.wrapAt(1+peers.indexOfEqual(source_peer));
		// send message to next peer with "np" identifier and the centroid
		p.sendMsg("/"++nextpeer++"/np", p.name, centroid.asString)
		}, "/np");
    }.fork;
);

// (
// local sound routine, streams I to O with dry/wet bandpass
// ~stream = { arg fc = 1000; // center freq of bandpass
// 	var wet = 0.5, gain = 0.8, sig = SoundIn.ar(0);
// 	// Out.ar(0, sig * gain);
// 	Out.ar(0, (BPF.ar(sig, fc.lag(0.1))*wet + sig*(1-wet)) * gain)
// }.play;
// )

// { [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;