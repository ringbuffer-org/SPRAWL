////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////

(
q.sendMsg("/ALL/set_clock_freq", 1);
q.sendMsg("/ALL/set_text_instructions", "Silence: Prepare for Section 2.")
)


////////////////////////////////////////////////////////////////////////////////////////////////
// Countown to START
////////////////////////////////////////////////////////////////////////////////////////////////

~start_countdown = {
	Routine({
		t = 5;
		while { t > 0 } { t = t - 1;

			q.sendMsg("/ALL/set_text_colors", 0);
			q.sendMsg("/ALL/set_text_instructions", "GO in:"+t.asString());
			1.wait;
			q.sendMsg("/ALL/set_text_colors", 1);
			1.wait;
		};
	}).play;
};


////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////


q.sendMsg("/ALL/set_text_instructions", " This section encapsulates the drama and power of the Cyber-Magdeburg Hemispheres experiment. It's a journey from isolation to connection, simplicity to complexity, and ignorance to enlightenment.");



q.sendMsg("/ALL/set_text_instructions", " It aims to underline how unseen forces—be they physical or digital—govern our world in ways that are monumental yet easily overlooked.");


q.sendMsg("/ALL/set_text_instructions", "10% of full force!")

q.sendMsg("/ALL/set_text_instructions", "The sonic space starts to constrict, mirroring the conceptual force between the Cyber-Magdeburg Hemispheres.")

q.sendMsg("/ALL/set_text_instructions", "20% of full force!")

q.sendMsg("/ALL/set_text_instructions", "Begin with sparse, repeating motifs")

q.sendMsg("/ALL/set_text_instructions", "sonic atoms—that accumulate and build in complexity")

q.sendMsg("/ALL/set_text_instructions", "30% of full force!")

q.sendMsg("/ALL/set_text_instructions", "tension grows")

q.sendMsg("/ALL/set_text_instructions", "evolve into a chaotic assembly of digital chatter")

q.sendMsg("/ALL/set_text_instructions", "data packets clashing and merging. ")

q.sendMsg("/ALL/set_text_instructions", "60% of full force!")


q.sendMsg("/ALL/set_text_instructions", "70% of full force!")

q.sendMsg("/ALL/set_text_instructions", "80% of full force!")

(
q.sendMsg("/ALL/set_text_instructions", "90% of full force!")
)


q.sendMsg("/ALL/set_text_instructions", "95% of full force!")

q.sendMsg("/ALL/set_text_instructions", "Soon: Conclude with a moment of release")

q.sendMsg("/ALL/set_text_instructions", "a sonic 'snap' that suggests the breaking of an invisible, yet almost palpable, tension.")









