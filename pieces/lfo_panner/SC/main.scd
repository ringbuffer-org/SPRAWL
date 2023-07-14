~n_chan = 15;
s.options.numOutputBusChannels = ~n_chan;
s.options.numInputBusChannels = 1;
s.waitForBoot(
    {
        "starting panner setup".postln;
        // Route input to outputs
        ~panner = {
            |freq = 0.2, own_gain = 0.3, lfo_choice = 0|

            var in = SoundIn.ar(0);
            // var pos = LFDNoise3.ar(freq, 10);
            var lfos = [LFSaw.ar(freq), SinOsc.ar(freq), LFDNoise3.ar(freq, 10)];
            var pos = SelectX.ar(lfo_choice, lfos);
            var out = PanAz.ar(~n_chan-1, in, pos);

            // monitor own input
            Out.ar(0, in*own_gain);

            // send panned output out
            Out.ar(1, out);
        }.play;

        {
            ~window = Window(bounds:800@480).front().background_(Color.black);
            ~slider_pan_speed = Slider2D(~window, Rect(10,10,780,430));
            ~text_pan_speed = TextField(~window, Rect(10,450,780,30)).string = "Pan Speed: 0.2";
            ~slider_pan_speed.action_({
                arg sl;
                var new_freq = (sl.x*10)**2;
                var new_lfo_type = sl.y * 2;
                ~panner.set(\freq, new_freq, \lfo_choice, new_lfo_type);
                ~text_pan_speed.string = "Pan Speed: " ++ new_freq.round(1e-2) ++ "Hz \tLFO Blend: " ++ new_lfo_type.round(1e-2) ++ " \t(0 Saw, 1 Sine, 2 Noise)";

            });
            ~window.fullScreen();
        }.defer;

    };
    , onFailure: {"[ERROR] failed to start the main routine".postln});
