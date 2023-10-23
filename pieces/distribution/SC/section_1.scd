////////////////////////////////////////////////////////////////////////////////////////////////
// Get ready
////////////////////////////////////////////////////////////////////////////////////////////////

(
q.sendMsg("/ALL/set_clock_freq", 1);
q.sendMsg("/ALL/set_text_instructions", "Silence: Prepare for Section 1.")
)

////////////////////////////////////////////////////////////////////////////////////////////////
// GO
////////////////////////////////////////////////////////////////////////////////////////////////

~start_gently.choose();

////////////////////////////////////////////////////////////////////////////////////////////////
// Text messages during the piece
////////////////////////////////////////////////////////////////////////////////////////////////


// Sonic Characteristics (1):
q.sendMsg("/ALL/set_text_instructions", "A delicate tapestry of ethereal textures and digital pulses.")

q.sendMsg("/ALL/set_text_instructions", "10% until end of section!")

// Narrative:
q.sendMsg("/ALL/set_text_instructions", "The section serves as a sonic portrait of Guericke’s early years")

//where the historical roots of Magdeburg meet the promise of a futuristic utopia.")

q.sendMsg("/ALL/set_text_instructions", "the wonder of a young mind")

q.sendMsg("/ALL/set_text_instructions", "a city caught between its storied past and its impending transformation into a cybernetic metropolis.")

q.sendMsg("/ALL/set_text_instructions", "30% until end of section!")

// Sonic Characteristics (2):
q.sendMsg("/ALL/set_text_instructions", "Introduce moments of sonic exploration")

q.sendMsg("/ALL/set_text_instructions", "Ambient waves coalesce into oscillating glitches!")

// suggesting a dialectic between the old and the new.")
q.sendMsg("/ALL/set_text_instructions", "50% until end of section!")

// Sonic Characteristics (3):
q.sendMsg("/ALL/set_text_instructions", "Evoke feelings of curiosity and possibility!")


q.sendMsg("/ALL/set_text_instructions", "70% until end of section!")

q.sendMsg("/ALL/set_text_instructions", "Peek into different realms of knowledge!!!!")


q.sendMsg("/ALL/set_text_instructions", "80% until end of section!")


q.sendMsg("/ALL/set_text_instructions", "A little more Exploration!!")


q.sendMsg("/ALL/set_text_instructions", "90% until end of section!")


////////////////////////////////////////////////////////////////////////////////////////////////
// END with fade out
////////////////////////////////////////////////////////////////////////////////////////////////

~fadeout_countdown.choose();




