NetAddr.new("localhost", 9494).sendMsg("/alert", "get ready");


~fc_BUS.scope

~text_routine.stop;

(
var r= 15;
~window.drawFunc = { |v|
    Pen.fillColor = Color.blue;
    Pen.strokeColor = Color.red;
    Pen.moveTo(150@150);
    Pen.arcTo(0@0, 200@225, r);
    Pen.arcTo(200@225, 100@225, r);
    Pen.arcTo(0@0, 100@150, r);
    Pen.arcTo(100@150, 150@150, r);
    Pen.lineTo(150@150);
    Pen.fillStroke;
};
)


(
//w = Window.new.front;
~window.view.background_(Color.white);
~window.drawFunc = {
	var cnt = 0;
    Pen.translate(100, 100);
	10.do{
        // set the Color
        Pen.color = Color.red(rrand(0.0, 1), rrand(0.0, 0.5));
		Pen.line([cnt,rand(100)], [cnt,rand(100)]);
        Pen.perform([\stroke, \fill].choose);
		cnt+=50;
	}
};
w.refresh;
)