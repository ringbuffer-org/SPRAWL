


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
q.sendMsg("/ALL/send_gains", *(Array.zeroFill(8)));

// only local speaker
q.sendMsg("/ALL/send_gains", 0.9, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);

q.sendMsg("/ALL/set_delay_times", 0, 0,0,0,0,0,0,0);

// wide spread delay
(
q.sendMsg("/ALL/send_gains", 0.7, 0.15, 0.15, 0.12, 0.12, 0.12, 0.12, 0.12);
q.sendMsg("/ALL/set_delay_times", 0, 0, 0.5212,0.3456,0.4345,0.5665,0.623234,0.5523234);
)

[0.8745, 0.5212,0.3456,0.4345,0.5665,0.623234

q.sendMsg("/ALL/send_gains", *((1..7)/20));

q.sendMsg("/ALL/set_delay_times", *((1..7)/100));




Array
(10..20)/19


*(1..2)