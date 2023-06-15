import sys
import cv2
from PyQt6.QtCore import Qt, QTimer, QUrl, pyqtSlot, QObject
from PyQt6.QtGui import QImage, QPixmap, QPainter
from PyQt6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt6.QtWidgets import QApplication
from PyQt6.QtQuick import QQuickPaintedItem
import asyncio

from PyQt6.QtCharts import QLineSeries, QChart, QValueAxis
import psutil

from video_tracking_obj import VideoTracking

class VideoItem(QQuickPaintedItem):
    engine = None

    def __init__(self, parent=None):
        super().__init__(parent)
        self.pixmap = None

    #def start(self):
        self.slider_value = 50
        
        #self.video_capture = cv2.VideoCapture(0)  # Replace with your desired video source

        self.vt = VideoTracking()
        asyncio.run(self.vt.init())
        
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update_frame)
        self.timer.start(30)  # Update every 30 milliseconds
    
    def update_frame(self):
        frame = self.vt.update()
        
        if frame != "":
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_GRAY2RGB)# cv2.COLOR_BGR2RGB)
            image = QImage(
                frame_rgb.data,
                frame_rgb.shape[1],
                frame_rgb.shape[0],
                QImage.Format.Format_RGB888
            )
            
            pixmap = QPixmap.fromImage(image)
            self.pixmap = pixmap.scaled(int(self.width()), int(self.height()), Qt.AspectRatioMode.KeepAspectRatio)
            
            self.update()
    
    def paint(self, painter):
        if self.pixmap:
            painter.drawPixmap(0, 0, self.pixmap)

    @pyqtSlot(int)
    def set_threshold(self, value):
        # print(f"Slider value changed: {value}")
        self.vt.set_threshold(value)

    @pyqtSlot(int)
    def set_smoothing(self, value):
        # print(f"Slider value changed: {value}")
        self.vt.set_smoothing(value)

    @pyqtSlot(int)
    def set_speed(self, value):
        # print(f"Slider value changed: {value}")
        self.timer.setInterval(value)

    @pyqtSlot(int)
    def set_sigma(self, value):
        # print(f"Slider value changed: {value}")
        self.vt.set_sigma(value)

    @pyqtSlot()
    def toggle_mode(self):
        print("Toggle mode")

    @pyqtSlot(str)
    def set_manual_osc_path(self, value):
        print(f"Setting OSC path: {value}")

    @pyqtSlot(str, str)
    def send_manual_osc(self, path, msg):
        print(f"Sending OSC msg: {msg} to path: {path}")
        self.vt.send_osc_msg(self.vt.transport, [path, msg.split(",")])

    @pyqtSlot(bool)
    def set_mod_volume(self, value):
        # print(f"Setting mod volume: {value}")
        self.vt.set_mod_volume(value)

    @pyqtSlot(bool)
    def set_pan_override(self, value):
        self.vt.set_pan_override(value)

if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Register the VideoItem type with the QML engine
    qmlRegisterType(VideoItem, "VideoItem", 1, 0, "VideoItem")
    
    engine = QQmlApplicationEngine()

    engine.load(QUrl.fromLocalFile("main.qml"))
    
    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())
