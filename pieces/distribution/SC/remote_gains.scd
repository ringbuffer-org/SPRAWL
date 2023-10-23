// a loos collection of lines to set gains and delays


 // send every input to every delay, except the one for the device the delay is sending to
(
~n_systems.do({
	|i|
	var gains = Array.fill(~n_systems, 0.5);
	gains[i] = 0;
	//gains[0] = 1;

	q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

})
)



// ALL OFF
q.sendMsg("/ALL/send_gains", *(Array.fill(~n_systems, 0)));

// only local speaker
q.sendMsg("/ALL/send_gains", 0.9, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);

q.sendMsg("/ALL/set_delay_times", 0.1, 0,0,0,0,0,0,0);

// wide spread delay
(
q.sendMsg("/ALL/send_gains", 0.7, 0.15, 0.15, 0.12, 0.12, 0.12, 0.12, 0.12);
q.sendMsg("/ALL/set_delay_times", 0, 0, 0.5212,0.3456,0.4345,0.5665,0.623234,0.5523234);
)

q.sendMsg("/ALL/send_gains", *((1..7)/20));

q.sendMsg("/ALL/set_delay_times", *((1..7)/100));





(10..20)/19


*(1..2)


// Reset all gains
(
q.sendMsg("/ALL/send_gains", *Array.fill(~n_systems, 0));
q.sendMsg("/ALL/set_delay_times", *Array.fill(~n_systems, 0));
~n_systems.do({
	|i|
	var gains = Array.fill(~n_systems, 0);
	q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

})
)

// Send only through own output
(
var gain_arr = Array.fill(~n_systems, 0);
gain_arr[0] = 1;
q.sendMsg("/ALL/send_gains", *gain_arr);
q.sendMsg("/ALL/set_delay_times", *Array.fill(~n_systems, 0));
q.sendMsg("/ALL/set_delay_input_gain", 0, *gain_arr);
(~n_systems-1).do({
	|i|
	var gains = Array.fill(~n_systems, 0);
	q.sendMsg("/ALL/set_delay_input_gain", i+1, *gains);

})
)

// short tempo delay, only send self
(
var feedback = 0.25;
var gain_arr = Array.fill(~n_systems, feedback);
gain_arr[0] = 1;
q.sendMsg("/ALL/send_gains", *gain_arr);
q.sendMsg("/ALL/set_delay_times", *Array.series(~n_systems, 0, ~clock_delta));
~n_systems.do({
	|i|
	var gains = Array.fill(~n_systems, 0);
	gains[0]=1;
	q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

})
)

// short tempo delay, also delay everything else
(
var gain_arr = Array.fill(~n_systems, 0.2);
gain_arr[0] = 1;
q.sendMsg("/ALL/send_gains", *gain_arr);
q.sendMsg("/ALL/set_delay_times", *Array.series(~n_systems, 0, ~clock_delta));
~n_systems.do({
	|i|
	var gains = Array.fill(~n_systems, 0.3);
	gains[0]=1;
	q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

})
)
// ultra_short tempo delay, also delay everything else
(
var gain_arr = Array.fill(~n_systems, 0.3);
q.sendMsg("/ALL/send_gains", *gain_arr);
q.sendMsg("/ALL/set_delay_times", *Array.series(~n_systems, 0, 0.001));
~n_systems.do({
	|i|
	var gains = Array.fill(~n_systems, 0);
	gains[0]=1;
	q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

})
)

// lomge delay, also delay everything else
(
var gain_arr = Array.fill(~n_systems, 0.3);
var delay_arr = Array.series(~n_systems, 1, 0.1);
delay_arr[0] = 0;
q.sendMsg("/ALL/send_gains", *gain_arr);
q.sendMsg("/ALL/set_delay_times", *delay_arr);
~n_systems.do({
	|i|
	var gains = Array.fill(~n_systems, 0);
	gains[0]=1;
	q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

})
)