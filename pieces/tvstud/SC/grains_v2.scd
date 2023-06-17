
s.waitForBoot(
    {
        ~samplepath = thisProcess.nowExecutingPath.dirname +/+ "samples";
        ~samples = SoundFile.collect(~samplepath +/+ "*");
        ~amplitude = Bus.control(s,1);
        ~freq = Bus.control(s,1);
        s.sync;
        ~bufs = Array.fill(~samples.size, {arg i; Buffer.read(s, ~samples[i].path)});
        s.sync;

        (
            SynthDef(\input_analyzer, {
                |out|
                var sig = SoundIn.ar(0);
                var fft, centroid;
                Out.kr(~amplitude, Amplitude.kr(sig,0.1, 0.03, mul:50));
                fft = FFT(LocalBuf(2048), SoundIn.ar(0));
                centroid = SpecCentroid.kr(fft)/1000;
                Out.kr(~freq, centroid);

            }).add;

        );
        s.sync;
        x = Synth(\input_analyzer);
        (
            SynthDef(\Grain, {
                | inBuf, rate=17|


                // ctrl params
                var ctrl_env = Env.new([0,0.1,0],[0.1,0.3]);
                var ctrl = In.kr(~amplitude) + (EnvGen.kr(ctrl_env, Dust.kr(1)));
                var freq_ctrl = In.kr(~freq);

                var rate_trig = rate + (ctrl * 15);
                var dur = (3+(8*ctrl))/rate_trig;

                var trigger_env = Env.linen(0,BufDur.kr(inBuf),0);
                var main_env = Env.linen(0, BufDur.kr(inBuf) + 0.3,0.1);

                var trigger = Impulse.kr(rate_trig) * EnvGen.kr(trigger_env);

                var pos = Line.kr(start:0, end:1,dur:BufDur.kr(inBuf))+(TRand.kr(0,3/BufDur.kr(inBuf),trigger)*ctrl);
                var rate_playback = 1 + WhiteNoise.kr(0.5*ctrl);
                var pan = WhiteNoise.kr(0.6);
                var sig_grains = GrainBuf.ar(2, trigger, dur:dur, sndbuf:inBuf, rate:rate_playback, pos:pos , pan:pan);
                ctrl.poll(10);
                Out.ar(0,sig_grains * EnvGen.kr(main_env, doneAction:2));
            }).add;
            y = Synth(\Grain, [\inBuf, ~bufs[5]]);
        );
        s.sync;
        r = Routine({inf.do({var buf = ~bufs.scramble[0]; Synth(\Grain, [\inBuf, buf]); (buf.duration + 0.5).wait })}).play;
    }

);