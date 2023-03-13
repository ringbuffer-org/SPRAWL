import easygui
from pythonosc import osc_server
from pythonosc import udp_client, dispatcher
import threading

 
def alert_handler(unused_addr, stri):
    
    easygui.msgbox(stri, title="Broadcast Message")    
    

dispatcher  = dispatcher.Dispatcher()       

dispatcher.map("/alert", alert_handler)

server = osc_server.ThreadingOSCUDPServer(( "127.0.0.1", 9494), dispatcher)       

t2 = threading.Thread(target=server.serve_forever)
t2.deamon = True
t2.start() 