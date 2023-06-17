~samplepath = thisProcess.nowExecutingPath.dirname +/+ "samples";
~amplitude = Bus.control(s,1);
~freq = Bus.control(s,1);
~amplitude.scope;
b = Buffer.read(s,"/home/shai/Downloads/Telegram Desktop/Theresa Zanon - Upsidedown V3.wav");
b = Buffer.read(s, ~samplepath +/+ "jasmin.wav");
b = Buffer.read(s, ~samplepath +/+ "ohneuns.wav");
b.play

(
SynthDef(\input_analyzer, {
    |out|
    var sig = SoundIn.ar(0);
    var fft, centroid;
    Out.kr(~amplitude, Amplitude.kr(sig,0.4, 0.1, mul:50));
    fft = FFT(LocalBuf(2048), SoundIn.ar(0));
    centroid = SpecCentroid.kr(fft)/1000;

    Out.kr(~freq, centroid);

}).add;
x.free;
x = Synth(\input_analyzer);
)


(
SynthDef(\Grain, {
    | inBuf, rate=17|
    var ctrl = In.kr(~amplitude);
    var rate_trig = rate + (ctrl * 15);
    var trigger = Impulse.kr(rate_trig);
    var dur = (3+(8*ctrl))/rate_trig;
    var pos = LFSaw.kr(1/BufDur.kr(inBuf), mul:0.5)+(TRand.kr(0,3/BufDur.kr(inBuf),trigger)*ctrl);
    var rate_playback = 1 + WhiteNoise.kr(0.5*ctrl);
    var pan = WhiteNoise.kr(0.6);
    var sig_grains = GrainBuf.ar(2, trigger, dur:dur, sndbuf:inBuf, rate:rate_playback, pos:pos , pan:pan);
    Out.ar(0,sig_grains);
}).add;
y.free;
y = Synth(\Grain, [\inBuf, b]);
)
y.free
y.set(\rate,100)

{WhiteNoise.kr(0.6)}.plot(3)
s.scope