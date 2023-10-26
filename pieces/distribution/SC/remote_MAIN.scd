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

	delay_times  = delay_times*~offset_SLIDER.value;
	~clock_delta = temp;

	q.sendMsg("/ALL/set_delay_times", *delay_times);
	delay_times.postln;
	// "Clock_Delta = "++temp.postln;

};


// this gain function is called by different sliders
~input_gain_callback = {


	var  input_gains;

	var input_slider = ~input_slider.value();

	input_gains = Array.fill(~n_systems, 0.4*input_slider);
	input_gains[0] = 1;

	~n_systems.do({
		|i|

		input_gains.postln;
		q.sendMsg("/ALL/set_delay_input_gain", i, *input_gains);
	})

};

~send_gain_callback = {
	var send_gains;

	var level = ~send_slider.value();
	var pos = ~send_xy.x * ~n_systems;
	var width = ~send_xy.y*4;



	send_gains = Array.fill(~n_systems, {
		arg i;
		var center = i-pos;
		var val = pow(1/((center*center)+1), width);
		if(val<0.001,{val=0.0});
		val;
	});

	send_gains[0] = max(send_gains[0], 0.3);
	send_gains = send_gains* (10 / (send_gains.sum()+10)) * level;
	q.sendMsg("/ALL/send_gains", *send_gains);
	send_gains.postln;


};

// GUI Main
{

	var mute_button, input_reset_button, delay_slider_text, send_slider_text, input_slider_text, tempo_slider_text, offset_slider_text;

	~main_gui_WINDOW = Window(name:"Audio Routing", bounds:Rect(200,400,1400,750));

	/*	~tempo_SLIDER = Slider(w, Rect(50, 50, 150, 400));
	~tempo_SLIDER.addAction({ |sl|
	var temp   = 0.1 + (sl.value * 4);
	~clock_delta = temp;
	temp.postln;
	});*/



	input_slider_text = StaticText(~main_gui_WINDOW,Rect(150,15, 123,30)).string_("INPUT").align_('center');
	~input_slider = Slider(~main_gui_WINDOW, Rect(150,55, 123,345));
	~input_slider.background = Color.red;
	~input_slider.addAction({~input_gain_callback.choose()});

	delay_slider_text = StaticText(~main_gui_WINDOW,Rect(250,15, 223,30)).string_("DELAY-Spread").align_('center');
	~delay_slider = Slider(~main_gui_WINDOW, Rect(300,55, 123,345));
	~delay_slider.background = Color.cyan;
	~delay_slider.addAction({~tempo_delay_callback.choose()});

	input_slider_text = StaticText(~main_gui_WINDOW,Rect(445,15, 123,30)).string_("SEND GAIN").align_('center');
	~send_slider = Slider(~main_gui_WINDOW, Rect(450,55, 123,345));
	~send_slider.background = Color.green;
	~send_slider.addAction({~send_gain_callback.choose()});

	~send_xy = Slider2D(~main_gui_WINDOW, Rect(650, 55, 645, 645));
	~send_xy.background = Color.green;
	~send_xy.addAction({~send_gain_callback.choose()});

	tempo_slider_text = StaticText(~main_gui_WINDOW,Rect(10,450, 123,30)).string_("TEMPO").align_('left');
	~tempo_SLIDER = Slider(~main_gui_WINDOW, Rect(100, 450, 500, 80));
	~tempo_SLIDER.background = Color.blue;
	~tempo_SLIDER.addAction({~tempo_delay_callback.choose()});

	offset_slider_text = StaticText(~main_gui_WINDOW,Rect(10,600, 123,60)).string_("CLOCK to Delay").align_('left');
	~offset_SLIDER = Slider(~main_gui_WINDOW, Rect(100, 600, 500, 80));
	~offset_SLIDER.background = Color.cyan;
	~offset_SLIDER.addAction({~tempo_delay_callback.choose()});

	mute_button = Button(~main_gui_WINDOW, Rect(10,55, 123,123));
	mute_button.states_([["MUTE ALL", Color.red, Color.yellow]]);
	mute_button.action_({~mute_all_gains_NET.choose()});

	input_reset_button = Button(~main_gui_WINDOW, Rect(10,255, 123,123));
	input_reset_button.states_([["Reset Input", Color.white, Color.red]]);
	input_reset_button.action_({~input_slider.valueAction_(0)});


	~main_gui_WINDOW.front;

}.value;



/*
// Tempo Slider GUI
{
w = Window(name:"Tempo Slider", bounds:Rect(400,400,300,500));
w.front;



}.value;
*/

~tempo_SLIDER.valueAction_(0.2);
~offset_SLIDER.valueAction_(1);




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