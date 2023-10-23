////////////////////////////////////////////////////////////////////////////////////////////////
// Get ready
////////////////////////////////////////////////////////////////////////////////////////////////


// TODO Tuning-Pause statt silence, danach silence
(
~clock_routine.reset();
q.sendMsg("/ALL/set_text_instructions", "Silence: Prepare for Section 3.")
)

////////////////////////////////////////////////////////////////////////////////////////////////
// fade it in
////////////////////////////////////////////////////////////////////////////////////////////////

~start_gently.choose();


////////////////////////////////////////////////////////////////////////////////////////////////
// NOTES
////////////////////////////////////////////////////////////////////////////////////////////////

"Here we explore Guericke's ascent to leadership, not just as a mayor but as a visionary whose policies and governance expand Cyber-Magdeburg into an interstellar haven. It's the story of how a single city can impact a galaxy, how one leader's vision can translate into universal harmony."

////////////////////////////////////////////////////////////////////////////////////////////////
// Text messages during the piece
////////////////////////////////////////////////////////////////////////////////////////////////

q.sendMsg("/ALL/set_text_instructions", "Start with a grandiose sweep of cascading tonal clusters.")


q.sendMsg("/ALL/set_text_instructions", "suggest a utopian expanse.")

q.sendMsg("/ALL/set_text_instructions", "10% until end of section!")

q.sendMsg("/ALL/set_text_instructions", "moments of celestial clarity—sonic beams")


q.sendMsg("/ALL/set_text_instructions", "30% until end of section!")

// of light—that puncture through like governing edicts or philosophical insights.
q.sendMsg("/ALL/set_text_instructions", "Let the sound swell in waves of resonance")


q.sendMsg("/ALL/set_text_instructions", "50% until end of section!")

q.sendMsg("/ALL/set_text_instructions", "building up.")

q.sendMsg("/ALL/set_text_instructions", "texture becomes a complex tapestry of interweaving sonic narratives.")

q.sendMsg("/ALL/set_text_instructions", "70% until end of section!")


q.sendMsg("/ALL/set_text_instructions", "narrow down ")

q.sendMsg("/ALL/set_text_instructions", "90% until end of section!")

q.sendMsg("/ALL/set_text_instructions", " -> synthesized bell or chime.")


q.sendMsg("/ALL/set_text_instructions", "signify unity amidst diversity.")



////////////////////////////////////////////////////////////////////////////////////////////////
// fade it out
////////////////////////////////////////////////////////////////////////////////////////////////

~fadeout_countdown.choose();