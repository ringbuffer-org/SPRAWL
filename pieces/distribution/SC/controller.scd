
q = P2PSC();


// send single text
q.sendMsg("/ALL/set_text_instructions", "SECTION 2 - NOW!")


q.sendMsg("/ALL/set_text_instructions", "More panache!")
q.sendMsg("/ALL/set_text_instructions", "Swooosh")


q.sendMsg("/ALL/set_text_instructions", "DAVE, komm klar!")


q.sendMsg("/ALL/set_text_instructions", "Less ACID!")


q.sendMsg("/ALL/set_text_instructions", "Geht los!");

q.sendMsg("/ALL/set_text_instructions", "99.9% of full force!")


q.sendMsg("/ALL/set_text_instructions", "Fade OUT - NOW, please!")


q.sendMsg("/ALL/set_clock_freq", 1.0);

q.sendMsg("/ALL/set_clock_freq", 0);

(
Routine({
	~peers = q.getPeers();
}).play;

~peers.size();

)



// send a COUNTDOWN
(
Routine({

	t = 20;
	while { t > 0 } { t = t - 1;

		q.sendMsg("/ALL/set_text_instructions", "Time to FINISH: "+t.asString());

		1.wait;
	};

	q.sendMsg("/ALL/set_text_instructions", "SILENCE!");

}).play;
)



// send a COUNTDOWN
(
Routine({


	loop({

		q.sendMsg("/ALL/set_text_instructions", "Fade OUT - NOW, please!");
		0.1.wait;
		q.sendMsg("/ALL/set_text_instructions", "")

	}).play;


}).play;
)


// Set Clock Frequency







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



// SEND ALL TO ALL

q.sendMsg("/ALL/out_gains", 1,1,1,1,1,1,1);
q.sendMsg("/ALL/out_gains", 0 , 0,0,0,0,0,0);
