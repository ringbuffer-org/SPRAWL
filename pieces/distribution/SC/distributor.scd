
~n_peers = 6;

// read n_peers from command line
if(size(thisProcess.argv)==1,
	{
		~n_peers = thisProcess.argv[0].asInteger;
});

// number of audio outputs for routing purposes is number of peers +1
~n_chan  = ~n_peers+1;

s.options.numInputBusChannels  = ~n_chan;

// an additional output is needed for the clocksignal
s.options.numOutputBusChannels = ~n_chan + 1;
s.options.device = "Distributor";

~input_OSC = 6666;
thisProcess.openUDPPort(~input_OSC);

s.waitForBoot(
	{
		// setup P2PSC
		p = P2PSC();
		~hostname = Pipe.new("hostname", "r").getLine;
		p.setName(~hostname); // set your name accordingly
		~hostname.post;
		s.sync();

		// GAIN BUSES
		// Gain for the own audio input
		~instrument_gain_bus   = Bus.control(s,1).set(1);

		~input_gain_bus  = Bus.control(s,1).set(0.9);
		~output_gain_bus = Bus.control(s,1).set(0.9);

		~delay_input_gain_buses = Array.fill(~n_chan, {Bus.control(s, ~n_chan)});

		~send_gain_buses  = Bus.control(s, ~n_chan).setAt(0, 0.5);
		~delay_time_buses = Bus.control(s, ~n_chan).setAll(0.1);

		~audio_router = SynthDef(\audiorouter,
			{
				var in_local   = SoundIn.ar(0,~instrument_gain_bus.kr);
				var in_network = Mix.ar(SoundIn.ar(Array.iota(~n_peers)+1));

				Out.ar(0, in_network);
		}).play;


		~delays = Array.fill(~n_chan, {
			arg i;
			{
				var index = i;
				// TODO readd instrument gain for soundin
				var in = SoundIn.ar(Array.iota(~n_chan));
				var in_gains = ~delay_input_gain_buses[index].kr;
				var delay_time = ~delay_time_buses.kr(1, index);
				var send_gain = ~send_gain_buses.kr(1, index);
				var instrument_gain = ~instrument_gain_bus.kr(1, index);
				var processed;
				in[0] = in[0] * instrument_gain;
				processed = DelayL.ar(Mix(in*in_gains), 1, delay_time);

				Out.ar(index, processed);

			}.play;
		});

		~clock_generator = {
			|freq = 1|
			Out.ar(~n_chan,LFPulse.ar(freq, width:0.5);
		)}.play;

		~window = Window(bounds:800@480).front().background_(Color.black);
		~window.fullScreen();

		~text_instructions = StaticText(~window, Rect(120, 10, 670, 200));
		~text_instructions.background = Color.white;
		~text_instructions.stringColor = Color.red;
		~text_instructions.align = \center;
		~text_instructions.font = Font("Monaco", 30);

		~text_instructions.string = "EOC Command text line test stuff.";

		~gain_slider_text = StaticText(~window, Rect(10, 5, 100, 50));
		~gain_slider_text.string_("GAIN").stringColor_(Color.green).align_(\center).font_(Font("Monaco", 28););
		~gain_slider = Slider(~window, Rect(10, 50, 100, 410));
		~gain_slider.addAction({|sl| ~instrument_gain_bus.set(sl.value)});
		~gain_slider.valueAction = 0.9;

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
				~send_gain_buses.setn(msg.asFloat);
			}{("Invalid Message Length, " ++ msg.size).postln};

		}, "/send_gains");*/

		p.addPath({ |msg|
			if(msg.size == (~n_chan+1)){
				msg.removeAt(0);
				~send_gain_buses.setn(msg.asFloat);
			}{("Invalid Message Length, " ++ msg.size).postln};
		}, "/send_gains");


		p.addPath({ |msg|

			{
				~text_instructions.string = msg[1];
			}.defer;

		}, "/set_text_instructions");


		p.addPath({ |msg|

				~clock_generator.set(\freq, msg[1].asFloat);

		}, "/set_clock_freq");


		p.addPath({ |msg|
						if(msg.size == (~n_chan+1)){
				msg.removeAt(0);
				~delay_time_buses.setn(msg.asFloat);
			}{("Invalid Message Length, " ++ msg.size).postln};
		}, "/set_delay_times");
};

);
