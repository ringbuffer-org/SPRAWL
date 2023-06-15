s.waitForBoot(
	{

		~b_num = 1 + 6.rand();

		~samplepath = thisProcess.nowExecutingPath.dirname +/+ "samples";

		s.sync;
		b = Buffer.read(s, ~samplepath +/+ "zems-0" ++ ~b_num ++ ".wav");

		s.sync;

		{
			var phase = Phasor.ar(
				rate: BufRateScale.kr(b),
				start: 0,
				end: BufFrames.kr(b)
			);

			var center = phase / 48000 + LFDNoise3.ar(15);

			var rate = 10;
			var dur = 5/rate;
			var trigger = Dust.kr(rate);



			var sig_og = BufRd.ar(
				1,
				b,
				phase: phase
			);
			var sig_grains = TGrains.ar(1, trigger, b, 1, center, dur);

			Out.ar(0, SelectX.ar(LFDNoise1.kr(0.3, 2), [sig_og, sig_grains]));



		}.play

	}
)