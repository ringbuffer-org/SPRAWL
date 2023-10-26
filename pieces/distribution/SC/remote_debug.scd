// trials and so on

[1] ++ [2, 3, 4]
~delays.do({|x| x.free})
~instrument_gain_bus.scope

q = P2PSC(port:12345)
q.sendMsg("/ALL/set_delay_input_gain", 0, *[1,0,0,0,0,0,0,0]);
q.sendMsg("/ALL/send_gains", *[1,0,0,0,0,0,0,0]);
q.sendMsg("/ALL/send_gains", *Array.fill(~n_chan, 0.1));
q.sendMsg("/ALL/trigger_clock", 1);
do
~n_peers = 6;
~n_chan = ~n_peers+1;


// send every input to every delay, except the one for the device the delay is sending to
(
~n_chan = 8;
~n_chan.do({
	|i|
	var gains = Array.fill(~n_chan, 1);
	gains[i] = 0;
	q.sendMsg("/ALL/set_delay_input_gain", i, *gains);

})
)

q.sendMsg("/ALL/trigger_clock", 0.001);
~clock_duration = 0.04;


// a loos collection of lines to set gains and delays

{
	// ALL OFF
	q.sendMsg("/ALL/send_gains", *(Array.fill(~n_systems, 0)));

	// only local speaker
	q.sendMsg("/ALL/send_gains", 0.9, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);

	q.sendMsg("/ALL/set_delay_times", 0.1, 0,0,0,0,0,0,0);

	// wide spread delay
	(
		q.sendMsg("/ALL/send_gains", 0.7, 0.15, 0.15, 0.12, 0.12, 0.12, 0.12, 0.12);
		q.sendMsg("/ALL/set_delay_times", 0, 0, 0.5212,0.3456,0.4345,0.5665,0.623234,0.5523234);
	);

	q.sendMsg("/ALL/send_gains", *((1..7)/20));

	q.sendMsg("/ALL/set_delay_times", *((1..7)/100));

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

};