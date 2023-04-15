s.options.numInputBusChannels = 3;
s.options.numOutputBusChannels = 3;
s.boot;

"started booting".postln;
s.waitForBoot(
    Routine({
        "Starting Delay Setup".postln;
        // Control Buses
        ~bus_feedback1 = Bus.control(s,1);
        ~bus_feedback2 = Bus.control(s,1);
        ~bus_delay1 = Bus.control(s,1);
        ~bus_delay2 = Bus.control(s,1);
        ~bus_mix1 = Bus.control(s,1);
        ~bus_mix2 = Bus.control(s,1);
        ~bus_gain = Bus.control(s,1);
        s.sync;

        // initial Bus Values
        ~bus_feedback1.set(0.5);
        ~bus_feedback2.set(0.5);
        ~bus_delay1.set(1.1);
        ~bus_delay2.set(1);
        ~bus_mix1.set(0.4);
        ~bus_mix2.set(0.1);
        ~bus_gain.set(0.5);

        // GUI goes here
        // inside defer to allow using GUI elements in the Routine
        {
            ~window = Window(bounds:800@480).front().background_(Color.black);
            ~width = 800;
            ~height = 480;
            ~margin = 10;
            ~width_slider = 60;
            ~width_xy = ((~width-(~width_slider*3)-(~margin*7))/2).asInteger;
            ~current_start = ~margin;

            ~slider_mix1 = Slider(~window,[~current_start,50,~width_slider,420]);
            ~current_start = ~current_start + ~margin + ~width_slider;

            ~slider_delay1 = Slider2D(~window,Rect(~current_start,50,~width_xy,420));
            ~current_start = ~current_start + ~margin + ~width_xy;

            ~slider_mix2 = Slider(~window,[~current_start,50,~width_slider,420]);
            ~current_start = ~current_start + ~margin + ~width_slider;

            ~slider_delay2 = Slider2D(~window,Rect(~current_start,50,~width_xy,420));
            ~current_start = ~current_start + ~margin + ~width_xy;

            ~slider_gain = Slider(~window, Rect(~current_start,50,~width_slider,420));

            ~slider_mix1.action_({
                arg sl;
                ~bus_mix1.set(sl.value);
            });
            ~slider_mix2.action_({
                arg sl;
                ~bus_mix2.set(sl.value);
            });
            ~slider_delay1.action_({
                arg sl;
                ~bus_feedback1.set(sl.y);
                ~bus_delay1.set(sl.x*2);
            });
            ~slider_delay2.action_({
                arg sl;
                ~bus_feedback2.set(sl.y);
                ~bus_delay2.set(sl.x*2);
            });
            ~slider_gain.action_({
                arg sl;
                ~bus_gain.set(sl.value);
            });

            // Textfields
            ~text_start = ~margin;
            ~text_mix1 = TextField(~window, Rect(~text_start,5,~width_slider,33)).string = "to 1:";
            ~text_start = ~text_start + ~margin + ~width_slider;

            ~text_del1 = TextField(~window, Rect(~text_start,5,(~width_xy/2).asInteger,33)).string = "delay time 1:";
            ~text_start = ~text_start + (~width_xy/2).asInteger;

            ~text_fb1  = TextField(~window, Rect(~text_start,5,(~width_xy/2).asInteger,33)).string = "feedback 1:";
            ~text_start = ~text_start + (~width_xy/2).asInteger + ~margin;

            ~text_mix2 = TextField(~window, Rect(~text_start,5,~width_slider,33)).string = "to 2:";
            ~text_start = ~text_start + ~margin + ~width_slider;

            ~text_del2 = TextField(~window, Rect(~text_start,5,(~width_xy/2).asInteger,33)).string = "delay time 2:";
            ~text_start = ~text_start + (~width_xy/2).asInteger;

            ~text_fb2  = TextField(~window, Rect(~text_start,5,(~width_xy/2).asInteger,33)).string = "feedback 2:";
            ~text_start = ~text_start + (~width_xy/2).asInteger + ~margin;

            ~text_gain = TextField(~window, Rect(~text_start,5,~width_slider,33)).string = "gain:";

            ~text_routine = Routine({
                loop{
                    ~bus_mix1.get({arg val; {~text_mix1.string = "to 1: " ++ val.round(1e-2);}.defer});
                    ~bus_mix2.get({arg val; {~text_mix2.string = "to 2: " ++ val.round(1e-2);}.defer});
                    ~bus_delay1.get({arg val; {~text_del1.string = "delay time 1: " ++ val.round(1e-2) ++ "s";}.defer});
                    ~bus_delay2.get({arg val; {~text_del2.string = "delay time 2: " ++ val.round(1e-2) ++ "s";}.defer});
                    ~bus_feedback1.get({arg val; {~text_fb1.string = "feedback 1: " ++ val.round(1e-2) ++ "%";}.defer});
                    ~bus_feedback2.get({arg val; {~text_fb2.string = "feedback 2: " ++ val.round(1e-2) ++ "%";}.defer});
                    ~bus_gain.get({arg val; {~text_gain.string = "gain: " ++ val.round(1e-2);}.defer});
                    0.1.wait;
                }
            }).play;

        }.defer;


        ~delay = SynthDef(\delay, {
            var in_main = SoundIn.ar(0);
            var in_remote_1 = SoundIn.ar(1);
            var in_remote_2 = SoundIn.ar(2);

            var fb_1 = In.kr(~bus_feedback1).lag(0.1);
            var fb_2 = In.kr(~bus_feedback2).lag(0.1);
            var delay_1 = In.kr(~bus_delay1).lag(0.1);
            var delay_2 = In.kr(~bus_delay2).lag(0.1);
            var mx_1 = In.kr(~bus_mix1).lag(0.1);
            var mx_2 = In.kr(~bus_mix2).lag(0.1);
            var gain = In.kr(~bus_gain).lag(0.1);

            var sig_main = in_main + in_remote_1 + in_remote_2;
            var sig_1 = ((in_main * mx_1) + (in_remote_1)) * fb_1;
            var sig_2 = ((in_main * mx_2) + (in_remote_2)) * fb_2;

            Out.ar(0, sig_main * gain);
            Out.ar(1, DelayL.ar(sig_1, 2, delay_1));
            Out.ar(2, DelayL.ar(sig_2, 2, delay_2));
        }).play(s);
    }).play;


    , onFailure: {"[ERROR]failed to start the main routine".postln});