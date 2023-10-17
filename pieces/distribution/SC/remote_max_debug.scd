[1] ++ [2, 3, 4]
~delays.do({|x| x.free})
~instrument_gain_bus.scope

q = P2PSC(port:12345)
q.sendMsg("/ALL/set_delay_input_gain", 0, *[1,0,0,0,0,0,0]);
q.sendMsg("/ALL/send_gains", 0,0.1,0.02,1,0.3,0,0.1, 0);
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