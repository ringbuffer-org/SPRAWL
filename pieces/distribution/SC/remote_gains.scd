// ALL OFF
q.sendMsg("/ALL/send_gains", *(Array.zeroFill(7)));

// only local speaker
q.sendMsg("/ALL/send_gains", 0.8,0.1,0.02,0,0,0,0);
q.sendMsg("/ALL/set_delay_times", 0, 0,0,0,0,0,0);

// wide spread delay
(
q.sendMsg("/ALL/send_gains", 0.75,0.12,0.12,0.12,0.12,0.12,0.12);
q.sendMsg("/ALL/set_delay_times", 0, 0.8745, 0.5212,0.3456,0.4345,0.5665,0.623234);
)

[0.8745, 0.5212,0.3456,0.4345,0.5665,0.623234

q.sendMsg("/ALL/send_gains", *((1..7)/20));

q.sendMsg("/ALL/set_delay_times", *((1..7)/100));




Array
(10..20)/19


*(1..2)