"SC_JACK_DEFAULT_INPUTS".setenv("REAPER");
//s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.numInputBusChannels = 16; // set to correct number of channels
s.options.numOutputBusChannels = 2; // set to correct number of channels
// s.options.maxLogins = 6; // set to correct number of clients
s.boot;
s.waitForBoot(
    {
        ~numInputs = 16; // set to correct number of channels
        ~netAverage = 0.0;
        ~scale_bools = [1, 1, 1, 1, 1];
        
        ~ownBus = Bus.new('audio', 18, 1, s);
        ~f1 = Buffer.alloc(s,1024,2);
        ~f2 = Buffer.alloc(s,1024,2);


        // Create the filterMix block
        ~filterMixBlock = {
            |cutoffFreq = 20000, vol = 1, gains = #[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]|

            // Create an array to hold the input signals
            var inputSignals = Array.fill(~numInputs, { |i| SoundIn.ar(i) });

            // Apply individual gains to the input signals
            var scaledInputs = inputSignals.collect({ |input, i| input * gains[i] });

            // Create a lowpass filter
            var filterOutput = LPF.ar(Mix.new(scaledInputs), cutoffFreq, vol);

            // Connect the filtered output to a SuperCollider audio output bus
            Out.ar(0, filterOutput);
            ScopeOut2.ar(filterOutput, ~f2.bufnum);
            
        
        }.play;

        ~nodeMix = {
            |delay = 0.5|
            Out.ar(~ownBus, SoundIn.ar(0));
            Out.ar(1, FreeVerb.ar(In.ar(~ownBus), 0.5, delay, 1-delay));
            ScopeOut2.ar(In.ar(~ownBus), ~f1.bufnum);
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

            if (~hostname.beginsWith("AP")) {
			    ~window.fullScreen;
            };

            // ScopeView
            ~text_scope1 = StaticText(~window, Rect(10, 5, 245, 20)).string = "Own input";
            // ~scopeView = ScopeView(~window, Rect(10,10,500,300));
            ~scopeView1 = ScopeView(~window, Rect(10,30,500,180));
            ~scopeView1.server = s;
            // ~scopeView.canFocus = true;
            ~scopeView1.bufnum = ~f1.bufnum;
            ~scopeView1.start;

            ~text_scope2 = StaticText(~window, Rect(10, 215, 245, 20)).string = "Mix result";
            // ~scopeView = ScopeView(~window, Rect(10,10,500,300));
            ~scopeView2 = ScopeView(~window, Rect(10,235,500,180));
            ~scopeView2.server = s;
            // ~scopeView.canFocus = true;
            ~scopeView2.bufnum = ~f2.bufnum;
            ~scopeView2.start;

            ~text_gains = StaticText(~window, Rect(10, 450, 780, 20)).string = "";

            // Monitor slider
            ~text_arp_slider = StaticText(~window, Rect(695, 5, 80, 30)).string = "Reverb";
			~slider_pan_speed = Slider(~window, Rect(695, 50, 80, 320));
            ~text_pan_speed = StaticText(~window, Rect(695, 385, 80, 30)).string = "";
            ~slider_pan_speed.action = { |slider|
                ~text_pan_speed.string = "Room size: " ++ slider.value.round(0.01);
                ~nodeMix.set(\delay, slider.value);
            };

            // Generate checkboxes
            ~checkboxHeight = (320 / 5.0).asInteger;
            ~spacing = (~checkboxHeight / 5.0).asInteger;
            ~yPos = 40;

            ~text_tones = StaticText(~window, Rect(560, 10, 150, 20)).string = "Arp tones";
            ~checkboxes = Array.fill(5, { |i|
                var checkbox = CheckBox.new(~window, Rect(560, ~yPos, 150, ~checkboxHeight), "Tone " ++ (i + 1));
                ~yPos = ~yPos + (~checkboxHeight + ~spacing);
                checkbox.value = ~scale_bools[i];
                checkbox.action = { |box|
                    if (box.value == true, {
                        ~scale_bools[i] = 1;
                    }, {
                        ~scale_bools[i] = 0;
                    });
                    ~scale_bools.postln;
                };
                checkbox;
            });

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
            var prog_idx = msg[1].asInteger;
            var chord_progression = msg.drop(2).round(0.001);
            var vol = (5 + 95.rand)/100.0;
            var freq = chord_progression[prog_idx];
            // chord_progression.postln; //print message for debugging

            if (~scale_bools[prog_idx] == 0, {
                freq = 0;
            });

            //{SinOsc.ar(freq:freq)*0.5*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
            {Out.ar(~ownBus, LFTri.ar(freq: freq) * vol * EnvGen.kr(Env.perc(releaseTime: sleeptime - 0.01), doneAction: 2))}.play;
            
        },"/synth"
        );

        "Start listening for shiftmix updates".postln;
        p.addPath({ |msg|
            var cutoffFreq = 20000*msg[1].asFloat/100.0;
            var delay = 2*msg[1].asFloat/100.0;
            var vol = msg[2].asFloat/100.0;
            var gains = msg.drop(3).round(0.001);

            // gains.round(0.001).postln; //print message for debugging

            ~filterMixBlock.set(\vol, vol);
            ~filterMixBlock.set(\gains, gains);
            ~filterMixBlock.set(\cutoffFreq, cutoffFreq);

            // ~gui.set(\gains, gains);
            {~text_gains.string = gains.round(0.1);
                // ~slider_pan_speed.value = vol;
            }.defer;

        },"/shiftmix"
        );
    }
);
s.meter;