~n_peers = 2;
~n_chan = ~n_peers+1;
s.options.numInputBusChannels = ~n_chan;
s.options.numOutputBusChannels = ~n_chan + 1;
s.options.device = "Distributor";

s.waitForBoot(
	{
		p = P2PSC();
		~hostname = Pipe.new("hostname", "r").getLine;
		p.setName(~hostname); // set your name accordingly
		~hostname.post;
		s.sync();

		~gain_buses = Bus.control(s, ~n_chan);

		~audio_router = SynthDef(\audiorouter,
			{
				var out_gains = ~gain_buses.kr;
				var in_main = SoundIn.ar(0);
				var in_ext = SoundIn.ar(Array.iota(~n_peers)+1);
				Out.ar(0, in_main!~n_chan*out_gains);
				Out.ar(0, Mix.new(in_ext));
		}).play;
		~clock_generator = {
			|freq = 1|
			Out.ar(~n_chan,LFPulse.ar(freq, width:0.5);
		)}.play;
/*
		OSCdef(\gains, {
			|msg, time, addr, recvPort|
			msg.postln;
			if(msg.size == (~n_chan+1)){
				msg.removeAt(0);
				~gain_buses.setn(msg.asFloat);
			}{("Invalid Message Length, " ++ msg.size).postln};

		}, "/out_gains");*/

		p.addPath({ |msg|
			if(msg.size == (~n_chan+1)){
				msg.removeAt(0);
				~gain_buses.setn(msg.asFloat);
			}{("Invalid Message Length, " ++ msg.size).postln};
		}, "/out_gains");
	};
	, onFailure: {"[ERROR]failed to start the main routine".postln});
