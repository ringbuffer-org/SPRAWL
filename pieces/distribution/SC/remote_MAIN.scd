
////////////////////////////////////////////////////////////////////////////////////////////////
// BASIC Startup
////////////////////////////////////////////////////////////////////////////////////////////////

(

// how many Access Points?
~n_systems = 8;

// launch a p2psc instance
q = P2PSC(ip:"localhost", port:1235);
q.name;

// load other scripts
~rootPath = PathName.new(thisProcess.nowExecutingPath).pathOnly;
load(~rootPath++"remote_gains.scd");

)

////////////////////////////////////////////////////////////////////////////////////////////////
// many things (evaluate as block)
////////////////////////////////////////////////////////////////////////////////////////////////
(

~clock_duration = 0.01;
~clock_delta    = 0.1;

~clock_routine = Routine({
	{
		q.sendMsg("/ALL/trigger_clock", ~clock_duration);
		~clock_delta.sleep;

	}.loop;
});


// this clock/delay function is called by different sliders
~tempo_delay_callback = {

	    var temp         = 0.1 + (~tempo_SLIDER.value * 4);

		var trim         = (temp* (~delay_slider.value));
		var other_delays = Array.series(~n_systems-1, temp, trim);
		var delay_times  = [0]++other_delays;

		~clock_delta = temp;

		q.sendMsg("/ALL/set_delay_times", *delay_times);

		"Clock_Delta = "++temp.postln;

		delay_times.postln;

};


// this gain function is called by different sliders
~gains_callback = {

	    var gain_arr = Array.fill(~n_systems-1, 0.2);
	    gain_arr[0] = 1;

	    q.sendMsg("/ALL/send_gains", *gain_arr);
	    // q.sendMsg("/ALL/set_delay_times", *Array.series(~n_systems, 0, ~clock_delta));
	    ~n_systems.do({
		|i|
		var gains = Array.fill(~n_systems, 0.3);
		gains[0]=1;
		q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

	})

};

// GUI Main
{

	var mute_button, delay_slider_text, send_slider_text, input_slider_text;

	~main_gui_WINDOW = Window(name:"Audio Routing", bounds:Rect(400,400,800,700));

	/*	~tempo_SLIDER = Slider(w, Rect(50, 50, 150, 400));
	~tempo_SLIDER.addAction({ |sl|
	var temp   = 0.1 + (sl.value * 4);
	~clock_delta = temp;
	temp.postln;
	});*/

	mute_button = Button(~main_gui_WINDOW, Rect(10,55, 123,123));
	mute_button.states_([["MUTE ALL", Color.white, Color.red]]);
	mute_button.action_({~mute_all_gains_NET.choose()});

	input_slider_text = StaticText(~main_gui_WINDOW,Rect(150,15, 123,30)).string_("INPUT").align_('center');
	~input_slider = Slider(~main_gui_WINDOW, Rect(150,55, 123,345));

	delay_slider_text = StaticText(~main_gui_WINDOW,Rect(300,15, 123,30)).string_("DELAYS").align_('center');
	~delay_slider = Slider(~main_gui_WINDOW, Rect(300,55, 123,345));
	~delay_slider.addAction({~tempo_delay_callback.choose()});

	input_slider_text = StaticText(~main_gui_WINDOW,Rect(450,15, 123,30)).string_("SEND").align_('center');
	~send_slider = Slider(~main_gui_WINDOW, Rect(450,55, 123,345));

	~tempo_SLIDER = Slider(~main_gui_WINDOW, Rect(100, 450, 500, 80));
	~tempo_SLIDER.addAction({~tempo_delay_callback.choose()});



	~main_gui_WINDOW.front;
}.value;



/*// Tempo Slider GUI
{
	w = Window(name:"Tempo Slider", bounds:Rect(400,400,300,500));
	w.front;



}.value;*/

~tempo_SLIDER.valueAction_(0.2);




// A gentle start:
~start_gently = {
	Routine({
		t = 10;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "Start gently - fade in now!");
			1.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			1.wait;
		};
	}).play;
};


// COUNTDOWN to GO:
~start_countdown = {
	Routine({
		t = 10;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "GO in:"+t.asString());
			1.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			1.wait;
		};

					q.sendMsg("/ALL/set_text_instructions", "GO NOW!");
	}).play;
};

// Fadeout COUNTDOWN:
~fadeout_countdown = {
	Routine({
		t = 20;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "Fade out - time to silence: "+t.asString());
			0.5.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			0.5.wait;
		};
		q.sendMsg("/ALL/set_text_instructions", "SILENCE!");

		~clock_routine.stop();

	}).play;
};


~climax_countdown = {
	Routine({
		t = 20;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "CRESCENDO climax in: "+t.asString());
			0.5.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			0.5.wait;
		};
		q.sendMsg("/ALL/set_text_instructions", "SILENCE!");
		~clock_routine.stop();

	}).play;
};



// Distribution Fader (not working yet)
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
};


)