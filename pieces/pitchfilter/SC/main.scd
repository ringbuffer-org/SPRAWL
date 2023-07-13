s.boot;

s.waitForBoot({{


	var sig;
	var sound;
	var input;
	var bandwidth = 0.1; // Bandbreite des Bandpassfilters
	var freq;
	var amp;

	sig = SoundIn.ar(1);
	input = SoundIn.ar([0]); // Eingangssignal auf den Kanälen 0 und 1
    freq = Pitch.kr(input, ampThreshold: 0.02, median: 7).cpsmidi.round(1).midicps;
	freq = freq.clip(100, 20000);
	amp = Amplitude.ar(input, mul:10.0);
    // Bandpassfilter mit dynamischer Frequenz einstellen

    sound = BPF.ar(sig, freq, bandwidth);
	sound = HPF.ar(sound,40);
	sound = LPF.ar(sound,20000);
    Out.ar(0, sound*amp);
}.play;}

)