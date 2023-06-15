import numpy as np
from scipy.stats import norm
import cv2
import asyncio
import pickle
from pythonosc.osc_message_builder import OscMessageBuilder
import logging
from typing import Tuple, Union

from pythonosc.osc_message import OscMessage
from pythonosc.osc_bundle import OscBundle
from p2psc.peerRegistry import PeerRegistry
from p2psc.peerInfo import PeerInfo, PeerType
from p2psc import proto

from ansible.inventory.manager import InventoryManager

class VideoTracking():
    def __init__(self):
        self._registry = PeerRegistry("video_tracking")
    
    async def init(self):
        # Create the UDP socket
        self.transport, _ = await asyncio.get_event_loop().create_datagram_endpoint(
            lambda: OscProtocolUdp(self), local_addr=('0.0.0.0', 57120), remote_addr=("127.0.0.1", 3765))

        # Register with the P2PSC
        self.connect()

        self.cap = cv2.VideoCapture(0) #4

        # Read nodes from Ansible hosts file
        hosts_file = '../../hosts'

        # Create an inventory manager
        inventory = InventoryManager(loader=None, sources=hosts_file)

        # Access groups
        all_groups = inventory.get_groups_dict()
        group_name = 'active_sprawl_nodes'
        self.nodes = all_groups[group_name]

        # Iterate over hosts
        for host in self.nodes:
            print(f'Group: {group_name}, Host: {host}')

        # Init vars
        self.last_image = ""
        self.threshold = 100
        self.smoothing = 0.9
        self.circ_x = 0
        self.circ_y = 0
        self.rad = 0

        self.sigma = 1
        self.mod_volume = False
        self.pan_override = False

    def connect(self):
        self.send_osc_msg(self.transport, ["/p2psc/peerinfo", [1, "T1 T2", "/test1 /test2"]])
        self.send_osc_msg(self.transport, ["/p2psc/name", ['video_tracking']])
        self.send_osc_msg(self.transport, ["/p2psc/peernames", []])

    def update(self):
            # Capture frame-by-frame
            ret, frame = self.cap.read()

            # Our operations on the frame come here
            gray = frame #cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

            frame_dilated = ""

            if (self.last_image != ""):
                frame_diff = cv2.absdiff(gray, self.last_image)

                frame_diff = cv2.cvtColor(frame_diff, cv2.COLOR_BGR2GRAY)

                ret, frame_thres = cv2.threshold(frame_diff, self.threshold, 255, cv2.THRESH_BINARY)

                frame_dilated = cv2.dilate(frame_thres, None, iterations=2)

                # Calc number of white pixels
                white_pixels = cv2.countNonZero(frame_dilated)
                # print('white pixels:', white_pixels)

                # do canny edge detection
                canny = cv2.Canny(frame_dilated, 100, 200)

                # get canny points
                # numpy points are (y,x)
                points = np.argwhere(canny>0)

                # get min enclosing circle
                center, radius = cv2.minEnclosingCircle(points)
                # print('center:', center, 'radius:', radius)

                # Apply smoothing to the x,y and radius
                if  (center[0] != 0 and center[1] != 0 and radius != 0):
                    self.circ_x = self.smoothing*self.circ_x + (1-self.smoothing)*center[1]
                    self.circ_y = self.smoothing*self.circ_y + (1-self.smoothing)*center[0]
                self.rad = 0.9*self.rad + 0.1*radius

                # Scale circ_x and circ_y to 0-100
                circ_x_perc = int(self.circ_x/gray.shape[1]*100)
                circ_y_perc = int(self.circ_y/gray.shape[0]*100)

                rad_perc = int(self.rad/max(gray.shape[0], gray.shape[1])*100)

                rad_perc = int(rad_perc/100*90+10)*2
                if (rad_perc > 100):
                    rad_perc = 100

                # self.send_osc_msg(self.transport, ["/ALL/shiftmix", [circ_x_perc, circ_y_perc, rad_perc]])
                #print(f"Sending OSC msg: {circ_x_perc}, {circ_y_perc}, {rad_perc}")

                new_vols = self.get_vol_distr(len(self.nodes), (circ_x_perc/100.0 if self.pan_override == False else self.smoothing))

                # Debug option
                # new_vols = self.get_vol_distr(4, (circ_x_perc/100.0 if self.pan_override == False else self.smoothing))
                # self.nodes = ['ALL']

                # Send shifts of gain list to nodes
                for i in range(len(self.nodes)):
                    self.send_osc_msg(self.transport, [f"/{self.nodes[i]}/shiftmix", [circ_y_perc, (rad_perc if self.mod_volume == True else 100), *np.roll(new_vols, i)]])

                cv2.circle(frame_dilated, (int(self.circ_x),int(self.circ_y)), int(self.rad), (255,255,255), 1)
                
            self.last_image = gray
            
            return frame_dilated

    def __del__(self):
        self.cap.release()
        self.transport.close()

    def get_vol_distr(self, number, shift):
        values = np.linspace(-number, number, 200)  # Generate values within a range
        pmf = norm.pdf(values, 0, self.sigma)
        vals = np.array_split(np.roll(pmf, int(np.round(shift*len(pmf)))), number)

        new_vols = []
        for i in range(number):
            new_vols.append(np.sum(vals[i]))

        norm_new_vols = new_vols / np.max(new_vols)
        return np.round(norm_new_vols,3)

    def set_threshold(self, val):
        print(f"Setting threshold: {val}")
        self.threshold = val

    def set_smoothing(self, val):
        print(f"Setting smoothing: {val}")
        self.smoothing = val/100.0

    def set_sigma(self, val):
        print(f"Setting sigma: {val}")
        self.sigma = val/10.0

    def set_mod_volume(self, val):
        print(f"Setting mod volume: {val}")
        self.mod_volume = val

    def set_pan_override(self, val):
        print(f"Setting pan override: {val}")
        self.pan_override = val

    def osc_message(self, path, args):
        mb = OscMessageBuilder(path)
        for a in args:
            mb.add_arg(a)
        return mb.build()

    def osc_dgram(self, path, args):
        mb = OscMessageBuilder(path)
        for a in args:
            mb.add_arg(a)
        return mb.build().dgram

    def send_osc_msg(self, transport, msg):
        # Serialize the message using pickle
        # serialized_message = pickle.dumps(msg)

        transport.sendto(self.osc_dgram(msg[0], msg[1]))

    
    async def on_osc(self, addr: Tuple[str, int], message: Union[OscBundle, OscMessage]):
        """ 
        Handle incoming OSC messages
        """
        if type(message) == OscBundle:
            logging.error("OSC Bundle messages are not supported yet!")
            return

        # Peerinfo messages are handled locally
        if proto.get_group_from_path(message.address) == proto.P2PSC_PREFIX:
            self._handle_local(addr, message)
            return

        # All other messages are forwarded to clients/nodes depending on sender
        try:
            peer_type = self._registry.get_peer(addr).type  # type: PeerInfo
        except LookupError:
            # If we don't know the peer we simply assume it is a client requesting us to forward the message
            # TODO: Any implications here?!
            peer_type = PeerType.client

        # Messages from clients are only forwarded to nodes
        if peer_type == PeerType.client:
            for pi in self._registry.get_by_path(message.address, filter_type=PeerType.node):
                logging.info(
                    f"Forwarding {message.address} {message.params} to {pi.addr}")
                self._transport.sendto(message.dgram, pi.addr)
        else:  # Messages from nodes are only forwarded to clients
            # remove group from path
            m = proto.osc_dgram(proto.remove_group_from_path(
                message.address), message.params)
            for pi in self._registry.get_by_path(message.address, filter_type=PeerType.client):
                self._transport.sendto(m, pi.addr)

class OscProtocolUdp(asyncio.DatagramProtocol):
    def __init__(self, handler):
        self._handler = handler
        self._transport = None  # type: asyncio.DatagramTransport

    def datagram_received(self, dgram, addr):
        """Called when a UDP message is received """

        # Parse OSC message
        try:
            if OscBundle.dgram_is_bundle(dgram):
                msg = OscBundle(dgram)
            elif OscMessage.dgram_is_message(dgram):
                msg = OscMessage(dgram)
            else:
                raise  # Invalid message
        except:
            logging.warning(f"Received invalid OSC from {addr}")
            return

        asyncio.ensure_future(self._handler.on_osc(addr, msg))

    def connection_made(self, transport):
        self._transport = transport

    def connection_lost(self, exc):
        logging.info(f"Connection lost: {str(exc)}")
        self._transport = None

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    vt = VideoTracking()

    asyncio.run(vt.main())
