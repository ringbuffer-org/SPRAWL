LanguageConfig.addIncludePath("/home/shai/Data/code/arbeit/akt/p2psc/libs/sclang")

p = P2PSC();
p.setName("Max");
(
p.addPath({ |msg|
	var sleeptime = 1;
	var freq= 200;
	msg.postln;
	{SinOsc.ar(freq:freq!2)*1*EnvGen.kr(Env.perc(releaseTime:sleeptime-0.01), doneAction:2)}.play;
}, "/ping");
)
100+1000.rand()

p.sendMsg("/ALL/huhuhu", "halo wie geht", 250)

fork{
	 ~peers = p.getPeers();
	"test".postln;
}
~peers.postln
p.getPeers();
o = Pipe.new("hostname", "r");
o.getLine.postln;


(
fork {
	var peer, peers;
	peers = p.getPeers().select({ |item| item.beginsWith("AP") });
	if (peers.size > 0,
		{
			peer = peers[0];
			("Sending initial ping to:"+peer).postln;
			("/"++peer++"/ping").postln;
			p.sendMsg("/"++peer++"/ping" , peers.reverse[0])
		},
		{"Error: No other peers in the network"}
	)
}
)
(
fork {
	var peer, peers;
	peers = p.getPeers().select({ |item| item.beginsWith("AP") });
	peers.postln;
	peers.size.postln;
}
)