
s.waitForBoot(
    {

    ~window = Window(bounds:800@480).front().background_(Color.black);

    ~window.fullScreen;


    ~button = Button(~window, Rect(100, 100, 600, 280));

    ~button.states = [["FIRE", Color.black, Color.red]];


    ~button.action = ({

    p.sendMsg("/"++nextpeer++"/ping", p.name)

    });

    ~window.front;

    }.defer;
);
