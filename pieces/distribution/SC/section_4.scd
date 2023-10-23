////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////

(
q.sendMsg("/ALL/set_text_instructions", "Silence: Prepare for Section 4.")
)

////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////

q.sendMsg("/ALL/set_text_instructions", "GO");


q.sendMsg("/ALL/set_text_instructions", "Focus on the ELECTRIC BASS!");

q.sendMsg("/ALL/set_text_instructions", "10% to end!")

(
q.sendMsg("/ALL/send_gains", 0.85,0.15,0,0,0,0,0);
q.sendMsg("/ALL/set_delay_times", 0, 0.83,0,0,0,0,0);
)

q.sendMsg("/ALL/set_text_instructions", "Oscillate between unpredictability and order.")


q.sendMsg("/ALL/set_text_instructions", "20% of the Section!")


q.sendMsg("/ALL/set_text_instructions", "Use rapid, complex sound structures")

q.sendMsg("/ALL/set_text_instructions", "Faster-than-light travel!!!!!");

q.sendMsg("/ALL/set_text_instructions", "Like sonic jumps through wormholes!!!!!");


q.sendMsg("/ALL/set_text_instructions", "50% of the Section!")

q.sendMsg("/ALL/set_text_instructions", "More fluid, organic tonal flows");


q.sendMsg("/ALL/set_text_instructions", "40% of the Section!")


q.sendMsg("/ALL/set_text_instructions", "An aural picture of the social and political philosophies that Guericke is developing for interstellar governance. ");

q.sendMsg("/ALL/set_text_instructions", "As the section progresses, allow these two elements—scientific marvel and civic order—to intertwine and resonate with each other, culminating in a symphonic synthesis.");

q.sendMsg("/ALL/set_text_instructions", "90% of the Section!")


q.sendMsg("/ALL/set_clock_freq", 0.25);

q.sendMsg("/ALL/set_text_instructions", "This section delves into Guericke's groundbreaking work in inventing the Interspace Pump, a device that makes interstellar travel commonplace.");

q.sendMsg("/ALL/set_text_instructions", "Simultaneously, it explores his formulation of new political philosophies designed for governing interconnected cosmic communities. The tension between science and governance resolves into a harmonious symbiosis.");



~fadeout_countdown = {
	Routine({
		t = 20;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "CRESCENDO: "+t.asString());
			0.5.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			0.5.wait;
		};
		q.sendMsg("/ALL/set_text_instructions", "SILENCE!");
		q.sendMsg("/ALL/set_clock_freq", 0);

	}).play;
};


