q = P2PSC();

q.name




q.sendMsg("/ALL/set_text_instructions", "More panache!")
q.sendMsg("/ALL/set_text_instructions", "Swooosh")


q.sendMsg("/ALL/set_text_instructions", "DAVE, komm klar!")


q.sendMsg("/ALL/set_text_instructions", "Less ACID!")

q.sendMsg("/ALL/set_text_instructions", "Geht los!");

q.sendMsg("/ALL/set_text_instructions", "90% of full force!")





(
Routine({
	~peers = q.getPeers();
}).play;

~peers.size();

)


////////////////////////////////////////////////////////////////////////////////////
// send a COUNTDOWN
////////////////////////////////////////////////////////////////////////////////////

(
Routine({
	t = 20;
	while { t > 0 } { t = t - 1;

		q.sendMsg("/ALL/set_text_colors", 0);
		q.sendMsg("/ALL/set_text_instructions", "Time to FINISH: "+t.asString());
		0.5.wait;
		q.sendMsg("/ALL/set_text_colors", 1);
		0.5.wait;
	};
	q.sendMsg("/ALL/set_text_instructions", "SILENCE!");
	q.sendMsg("/ALL/set_clock_freq", 0);

}).play;
)


////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////
(
~color_ROUTINE = Routine({

	loop(
	{
		q.sendMsg("/ALL/set_text_colors", 0);
		0.1.sleep;
		q.sendMsg("/ALL/set_text_colors", 1);
		0.1.sleep;
	};);
}).play;
)

~color_ROUTINE.stop;



////////////////////////////////////////////////////////////////////////////////////
// Set Clock Frequency
////////////////////////////////////////////////////////////////////////////////////






// A r


(

~pos = 0;

Routine({

	x = true;
	f = 1;

	while {x}
	{
		var gains = 0.0!7;
		gains[~pos] = 1.0;
		q.sendMsg("/ALL/out_gains", gains[0] ,gains[1] ,gains[2],gains[3],gains[4],gains[5],gains[6]);
		~pos = ~pos + 1 % 7;
		f.sleep;
	};
	"finished_routine".postln;}).play;
)



Array.iota(2)+1
~gain_buses.scope
x = false
f=0.1



