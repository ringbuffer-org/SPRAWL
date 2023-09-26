~n_peers = 6;
~n_chan = ~n_peers+1;
s.options.numInputBusChannels = ~n_chan;
s.options.numOutputBusChannels = ~n_chan + 1;
s.options.device = "Distributor";

~input_OSC = 6666;
thisProcess.openUDPPort(~input_OSC);

s.waitForBoot(
	{
		p = P2PSC();
		~hostname = Pipe.new("hostname", "r").getLine;
		p.setName(~hostname); // set your name accordingly
		~hostname.post;
		s.sync();

		~gain_buses = Bus.control(s, ~n_chan);
		~gain_buses.setAt(0, 0.5);

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

		~window = Window(bounds:800@480).front().background_(Color.black);
		~window.fullScreen();

		~text_instructions = StaticText(~window, Rect(10, 10, 780, 50));
		~text_instructions.background = Color.white;
		~text_instructions.stringColor = Color.red;
		~text_instructions.align = \center;
		~text_instructions.font = Font("Monaco", 30);

		~text_instructions.string = "EOC Command text line test stuff.";

/*		OSCdef(\set_clock_freq, {

			|msg, time, addr, recvPort|

			~clock_generator.set(msg[1].asFloat);

		}, "/set_clock_freq");*/


		// OSCdef(\set_text_instructions, {
		//
		// 	|msg, time, addr, recvPort|
		//
		// 	{
		// 		~text_instructions.string = msg[1];
		// 	}.defer
		// }, "/set_text_instructions");

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


		p.addPath({ |msg|

			{
				~text_instructions.string = msg[1];
			}.defer;

		}, "/set_text_instructions");


		p.addPath({ |msg|

				~clock_generator.set(\freq, msg[1].asFloat);

		}, "/set_clock_freq");
};

);
