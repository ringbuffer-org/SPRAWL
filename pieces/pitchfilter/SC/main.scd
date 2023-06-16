(x= {
	var sig;
	var sound;
	var input;
	var bandwidth = 3.0; // Bandbreite des Bandpassfilters
	var freq;
	sig = PinkNoise.ar(0.5!2);
	input = SoundIn.ar([0, 1]); // Eingangssignal auf den Kanälen 0 und 1
    freq = Pitch.kr(input, ampThreshold: 0.02, median: 7).cpsmidi.round(1).midicps;

    // Bandpassfilter mit dynamischer Frequenz einstellen

    sound = BPF.ar(sig, freq, bandwidth);
	sound = HPF.ar(sound,40);
	sound = LPF.ar(sound,20000);
    Out.ar(0, sound);
}.play;
)
x.free;
(y={

	var sig;
	var sound;
	var input;
	var bandwidth = 2.0; // Bandbreite des Bandpassfilters
	var freq;
~scale = Scale.minorPentatonic; // Tonleiter: A moll pentatonisch
~rootNote = 55; // A (MIDI-Notenwert)
~chord = Array.fill(3, { |i| ~scale.degrees[i % ~scale.degrees.size] + ~rootNote });
~chord = ~chord.midicps;

	sig = Mix.ar(SinOsc.ar(~chord, 0, 0.5));

	input = SoundIn.ar([0, 1]); // Eingangssignal auf den Kanälen 0 und 1
    freq = Pitch.kr(input, ampThreshold: 0.02, median: 7).cpsmidi.round(1).midicps;

    // Bandpassfilter mit dynamischer Frequenz einstellen

    sound = BPF.ar(sig, freq, bandwidth);
	sound = HPF.ar(sound,20);
    Out.ar(0, sound);
}.play;
)
y.free;
s.freeAll;