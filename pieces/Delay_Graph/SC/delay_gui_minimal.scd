s.options.numInputBusChannels = 3;
s.options.numOutputBusChannels = 3;

s.waitForBoot(
    Routine({
        "Starting Delay Setup".postln;

        ~delay = {
            | send_gain_1=0.7, send_gain_2=0.7,delay_1=0.3, delay_2=0.32, gain=0.9 |
            var in_main = SoundIn.ar(0);
            var in_remote_1 = SoundIn.ar(1);
            var in_remote_2 = SoundIn.ar(2);

            var sig_main = in_main + in_remote_1 + in_remote_2;
            var sig_1 = ((in_main) + (in_remote_1)) * send_gain_1.lag(0.1);
            var sig_2 = ((in_main) + (in_remote_2)) * send_gain_2.lag(0.1);

            Out.ar(0, sig_main * gain);
            Out.ar(1, DelayL.ar(sig_1, 2, delay_1.lag(0.1)));
            Out.ar(2, DelayL.ar(sig_2, 2, delay_2.lag(0.1)));
        }.play;

        // GUI goes here
        // inside defer to allow using GUI elements in the Routine
        {
            ~window = Window(bounds:800@480).front().background_(Color.black);

            ~slider_delay1 = Slider2D(~window,Rect(10,50,385,420));
            ~slider_delay2 = Slider2D(~window,Rect(405,50,385,420));

            // Textfields
            ~text_del1 = TextField(~window, Rect(10,5,190.asInteger,33)).string = "delay time 1:";
            ~text_fb1  = TextField(~window, Rect(210,5,190,33)).string = "feedback 1:";

            ~text_del2 = TextField(~window, Rect(405,5,190,33)).string = "delay time 2:";
            ~text_fb2  = TextField(~window, Rect(605,5,190,33)).string = "feedback 2:";

            ~slider_delay1.action_({
                arg sl;
                ~delay.set(\send_gain_1, sl.y);
                ~delay.set(\delay_1, sl.x*2);
                ~text_del1.string = "delay time 1: " ++ (sl.x*2).round(1e-2) ++ "s";
                ~text_fb1.string = "feedback 2: " ++ sl.y.round(1e-2) ++ "%";
            });
            ~slider_delay2.action_({
                arg sl;
                ~delay.set(\send_gain_2, sl.y);
                ~delay.set(\delay_2, sl.x*2);
                ~text_del2.string = "delay time 1: " ++ (sl.x*2).round(1e-2) ++ "s";
                ~text_fb2.string = "feedback 2: " ++ sl.y.round(1e-2) ++ "%";
            });
			~window.fullScreen();
        }.defer;
    }).play;


    , onFailure: {"[ERROR] failed to start the main routine".postln});