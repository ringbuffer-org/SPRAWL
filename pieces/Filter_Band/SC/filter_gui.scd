s.boot;

s.waitForBoot(

	Routine({

		// All control buses:
		~fc_BUS   = Bus.control(s,1);
		~rq_BUS   = Bus.control(s,1);
		~gain_BUS = Bus.control(s,1);

		s.sync;

		// Buses' initial values:
		~fc_BUS.set(1000);
		~rq_BUS.set(1);
		~gain_BUS.set(0);

		// The complete GUI section -
		// inside *defer* to allow using GUI elements in the Routine:
		{
			~window = Window(bounds:800@480).front().background_(Color.black);

			//~window.fullScreen;

			~slider = Slider2D(~window,Rect(10,50,700,420));

			~slider.action_(
				{
					arg sl;
					~fc_BUS.set(sl.x*10000+50);
					~rq_BUS.set((1-sl.y)*2+0.05);
				}
			);

			~slider.background_(Color.cyan(1,1));
			~slider.knobColor_(Color.cyan(1,1));

			~gain_slider = Slider(~window,[720,50,50,420]);

			~gain_slider.action_({
				arg sl;
				~gain_BUS.set(sl.value);
				});

			~slider.setXYActive(0.5,0.5);

			~fc_text   = TextField(~window, Rect(10,5,100,33)).string  = "f:";
			~rq_text   = TextField(~window, Rect(200,5,100,33)).string = "rq:";
			~gain_text = TextField(~window, Rect(700,5,100,33)).string = "gain:";

			// This routine updates the text feedback on control bus values:
			~text_routine = Routine {

				loop{
					~fc_BUS.get({arg val; {~fc_text.string = "f: "++val.asInteger;}.defer});
					~rq_BUS.get({arg val; {~rq_text.string = "rq: "++val.round(1e-3);}.defer});
					~gain_BUS.get({arg val; {~gain_text.string = "gain: "++val.round(1e-2);}.defer});
					0.1.wait;
				}
			}.play;

		}.defer;


		// Create a bandpass filter node via SynthDef:
		~filter = SynthDef(\bp_filter, {
			var in  = SoundIn.ar(0);

			var fc   = Lag.kr(In.kr(~fc_BUS),0.1);
			var rq   = Lag.kr(In.kr(~rq_BUS),0.1);
			var gain = Lag.kr(In.kr(~gain_BUS),0.1);

			var sig = BPF.ar(in,fc,rq) * (1/(rq+0.1));
			// var sig = Ringz.ar(in, fc, rq);
			Out.ar(0,gain*[sig,sig]);
			//
		}).play(s);

	}).play;

);
