
// MUTE all gains
~mute_all_gains_NET = {
	q.sendMsg("/ALL/send_gains", *Array.fill(~n_systems, 0));
	// q.sendMsg("/ALL/set_delay_times", *Array.fill(~n_systems, 0));

	~n_systems.do({ |i|
		var gains = Array.fill(~n_systems, 0);
		q.sendMsg("/ALL/set_delay_input_gain", i, *gains);
	});
	//"Muted all!".postln;
};


// Send only through own output
~direct_local_NET = {

	var gain_arr = Array.fill(~n_systems, 0);
	gain_arr[0] = 1;
	q.sendMsg("/ALL/send_gains", *gain_arr);
	// q.sendMsg("/ALL/set_delay_times", *Array.fill(~n_systems, 0));
	q.sendMsg("/ALL/set_delay_input_gain", 0, *gain_arr);
	(~n_systems-1).do({
		|i|
		var gains = Array.fill(~n_systems, 0);
		q.sendMsg("/ALL/set_delay_input_gain", i+1, *gains);

	})
};

// short tempo delay, only send self
~clocked_delay_self_NET = {

	var feedback = 0.25;
	var gain_arr = Array.fill(~n_systems, feedback);
	gain_arr[0] = 1;
	q.sendMsg("/ALL/send_gains", *gain_arr);
	// q.sendMsg("/ALL/set_delay_times", *Array.series(~n_systems, 0, ~clock_delta));
	~n_systems.do({
		|i|
		var gains = Array.fill(~n_systems, 0);
		gains[0]=1;
		q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

	})
};

// short tempo delay, also delay everything else
~clocked_delay_all_NET = {
	var gain_arr = Array.fill(~n_systems, 0.2);
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

// ultra_short tempo delay, also delay everything else
~ultra_short_tempo_delay_NET = {
	var gain_arr = Array.fill(~n_systems, 0.3);
	q.sendMsg("/ALL/send_gains", *gain_arr);
	// q.sendMsg("/ALL/set_delay_times", *Array.series(~n_systems, 0, 0.001));
	~n_systems.do({
		|i|
		var gains = Array.fill(~n_systems, 0);
		gains[0]=1;
		q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

	})
};

// lomge delay, also delay everything else
~long_delay_on_all_NET = {

	var gain_arr = Array.fill(~n_systems, 0.3);
	var delay_arr = Array.series(~n_systems, 1, 0.1);
	delay_arr[0] = 0;
	q.sendMsg("/ALL/send_gains", *gain_arr);
	// q.sendMsg("/ALL/set_delay_times", *delay_arr);
	~n_systems.do({
		|i|
		var gains = Array.fill(~n_systems, 0);
		gains[0]=1;
		q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

	})
};

