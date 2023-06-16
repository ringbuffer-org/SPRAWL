//"SC_JACK_DEFAULT_INPUTS".setenv("REAPER");
//s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.numInputBusChannels = 16; // set to correct number of channels
s.options.numOutputBusChannels = 2; // set to correct number of channels
// s.options.maxLogins = 6; // set to correct number of clients
s.boot;
s.waitForBoot(
    {
        ~numInputs = 16; // set to correct number of channels
        ~netAverage = 0.0;
        ~delay = 2;
        
        ~f = Buffer.alloc(s,1024,2);


        // Create the filterMix block
        ~filterMixBlock = {
            |cutoffFreq = 20000, vol = 1, delay = 2, gains = #[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]|

            // Create an array to hold the input signals
            var inputSignals = Array.fill(~numInputs, { |i| SoundIn.ar(i) });

            // Apply individual gains to the input signals
            var scaledInputs = inputSignals.collect({ |input, i| input * gains[i] });

            // Create a lowpass filter
            var filterOutput = LPF.ar(Mix.new(scaledInputs), cutoffFreq, vol);

            // Connect the filtered output to a SuperCollider audio output bus
            Out.ar(0, filterOutput);
            ScopeOut2.ar(filterOutput, ~f.bufnum);
        
        }.play;

		p = P2PSC();
		~hostname = Pipe.new("hostname", "r").getLine;
		p.setName(~hostname); // set your name accordingly
		~hostname.postln;
		s.sync();

        // Setups GUI
        // Routine(
		// {{
			~window = Window(bounds:800@480).front().background_(Color.white);

			~window.fullScreen;

            // ScopeView
            ~text_scope = StaticText(~window, Rect(10, 10, 780, 20)).string = "Mix result";
            // ~scopeView = ScopeView(~window, Rect(10,10,500,300));
            ~scopeView = ScopeView(~window, Rect(10,40,500,400));
            ~scopeView.server = s;
            ~scopeView.canFocus = true;
            ~scopeView.bufnum = ~f.bufnum;
            ~scopeView.start;

            ~text_gains = StaticText(~window, Rect(10, 460, 780, 20)).string = "";

            // Monitor slider
			~slider_pan_speed = Slider(~window, Rect(600, 110, 150, 320));
            ~text_pan_speed = StaticText(~window, Rect(600, 440, 150, 30)).string = "Mon.gain: 0.2";

			~window.front; 
        // }.defer;});

        "Start listening for pings".postln;
		p.addPath({ |msg|

			var sleeptime = 1;
            var freq = 100 + 1000.rand; // Change this for every node
            var pan = 2*msg[1].asFloat/100.0 - 1;
            var pitch = 300*msg[2].asFloat/100.0;
            var vol = msg[3].asFloat/100.0;
            freq = pitch;
            msg.postln; //print message for debugging

            //{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
            {Pan2.ar(SinOsc.ar(freq: freq) * 0.5 * EnvGen.kr(Env.perc(releaseTime: sleeptime - 0.01), doneAction: 2), pan, vol)}.play;

            fork {
                var nextpeer;
                var source_peer = msg[1].asString;
                var peers = p.getPeers().select({ |item| item.beginsWith("AP") });
                sleeptime.wait; // wait for one second

                // send to the next peer in our list
                nextpeer = peers.wrapAt(1+peers.indexOfEqual(source_peer));

                p.sendMsg("/"++nextpeer++"/ping", p.name);
            };

        },"/ping"
        );

        "Start listening for synth inputs".postln;
		p.addPath({ |msg|

			var sleeptime = 1;
            var freq = msg[1].asFloat;
            var vol = (5 + 95.rand)/100.0;
            msg.postln; //print message for debugging

            //{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
            {FreeVerb.ar(LFTri.ar(freq: freq) * vol * EnvGen.kr(Env.perc(releaseTime: sleeptime - 0.01), doneAction: 2), 0.5, ~delay, 0.5)}.play;
            ~text_gains.string = msg.asString;
        },"/synth"
        );

        "Start listening for shiftmix updates".postln;
        p.addPath({ |msg|
            var cutoffFreq = 20000*msg[1].asFloat/100.0;
            var delay = 2*msg[1].asFloat/100.0;
            var vol = msg[2].asFloat/100.0;
            var gains = msg.drop(3).round(0.001);

            // gains.round(0.001).postln; //print message for debugging
            ~delay = delay;

            ~filterMixBlock.set(\vol, vol);
            ~filterMixBlock.set(\gains, gains);
            ~filterMixBlock.set(\cutoffFreq, cutoffFreq);
            ~filterMixBlock.set(\delay, delay);

            // ~gui.set(\gains, gains);
            {~text_gains.string = gains.round(0.1);
            ~slider_pan_speed.value = vol;
            }.defer;

        },"/shiftmix"
        );
    }
);