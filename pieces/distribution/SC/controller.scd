
q = P2PSC();


// send single text

q.sendMsg("/ALL/set_text_instructions", "!")


//

(
Routine({
	~peers = q.getPeers();
}).play;
~peers
)



Array.iota(2)+1
~gain_buses.scope
x = false
f=0.1

(
~pos = 0;
Routine({
while {x}{
	var gains = 0.0!3;
	gains[~pos] = 1.0;
	q.sendMsg("/ALL/out_gains", gains[0] ,gains[1] ,gains[2]);
	~pos = ~pos + 1 % 3;
	f.sleep;
};
	"finished_routine".postln;}).play
)