~n_chan = 14;
s.options.numOutputBusChannels = ~n_chan;
s.options.numInputBusChannels = 1;
s.waitForBoot(
    {
        "starting panner setup".postln;
        // Route input to outputs
        ~panner = {
            |freq = 0.2, own_gain = 0.3|

            var in = SoundIn.ar(0);
            var pos = LFDNoise3.ar(freq, 10);
            var out = PanAz.ar(~n_chan-1, in, pos);

            // monitor own input
            Out.ar(0, in*own_gain);

            // send panned output out
            Out.ar(1, out);
        }.play;

        {
            ~window = Window(bounds:800@480).front().background_(Color.black);
            ~slider_pan_speed = Slider(~window, Rect(10,10,780,430));
            ~text_pan_speed = TextField(~window, Rect(10,450,780,30)).string = "Pan Speed: 0.2";
            ~slider_pan_speed.action_({
                arg sl;
                var new_freq = (sl.value*10)**3;
                ~panner.set(\freq, new_freq);
                ~text_pan_speed.string = "Pan Speed: " ++ new_freq.round(1e-2) ++ "Hz";

            });
            ~window.fullScreen();
        }.defer;

    };
    , onFailure: {"[ERROR] failed to start the main routine".postln});
