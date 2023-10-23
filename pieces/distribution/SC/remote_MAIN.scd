
////////////////////////////////////////////////////////////////////////////////////////////////
// BASIC Startupŝ
////////////////////////////////////////////////////////////////////////////////////////////////

(
q = P2PSC(ip:"localhost", port:1235);
q.name;
~n_systems = 8;
)

(

~clock_delta    = 1;
~clock_duration = 0.001;

~clock_routine = Routine({
	{
		q.sendMsg("/ALL/trigger_clock", ~clock_duration);

		~clock_delta.sleep;

	}.loop;
});

~clock_routine.play();

////////////////////////////////////////////////////////////////////////////////////////////////
// Tempo Slider GUI
////////////////////////////////////////////////////////////////////////////////////////////////


{
	w = Window(name:"Tempo Slider", bounds:Rect(400,400,300,500));
	w.front;

	~tempo_SLIDER = Slider(w, Rect(50, 50, 150, 400));

	~tempo_SLIDER.addAction({ |sl|

		var temp   = 0.1 + (sl.value * 4);

		~clock_delta = temp;

		temp.postln;

	});

}.value;




////////////////////////////////////////////////////////////////////////////////////
//   COUNTDOWN to GO
////////////////////////////////////////////////////////////////////////////////////

~start_countdown = {
	Routine({
		t = 10;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "GO");
			1.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			1.wait;
		};
	}).play;
};



////////////////////////////////////////////////////////////////////////////////////
// Fadeout COUNTDOWN
////////////////////////////////////////////////////////////////////////////////////

~start_countdown = {
	Routine({
		t = 10;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "GO");
			1.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			1.wait;
		};
	}).play;
};


////////////////////////////////////////////////////////////////////////////////////
// Fadeout COUNTDOWN
////////////////////////////////////////////////////////////////////////////////////

~fadeout_countdown = {
	Routine({
		t = 20;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "Fade - time to silence: "+t.asString());
			0.5.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			0.5.wait;
		};
		q.sendMsg("/ALL/set_text_instructions", "SILENCE!");
		q.sendMsg("/ALL/set_clock_freq", 0);

	}).play;
};



////////////////////////////////////////////////////////////////////////////////////////////////
// Distribution Fader
////////////////////////////////////////////////////////////////////////////////////////////////

{
	var window      = Window(name:"Section 1 Controls", bounds:Rect(400,400,800,800));
	var slider_TEXT = StaticText(window, Rect(20, 20, 150, 20)).align_(\center).background_(Color.rand).string_("asd");

	var distribution_SLIDER = Slider(window, Rect(50, 50, 50, 400));

	window.front;

	distribution_SLIDER.addAction({ |sl|

		var val   = sl.value;
		var gains = Array.series(8,1,-1*val/~n_systems);

		gains.postln;

	});
}.value;
)