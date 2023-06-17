import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import VideoItem 1.0
// import QtCharts 2.15

ApplicationWindow {
    width: 640
    height: 680
    visible: true
    title: qsTr("Camera OSC interaction")

    // Handle keyboard interrupt
    onClosing: {
        Qt.quit();
    }

    GridLayout {
        id: grid
        columns: 2
        rows: 8
        columnSpacing : spacing
	    rowSpacing : spacing
        anchors.fill: parent

        VideoItem {
            id: videoItem
            Layout.rowSpan: 2
            Layout.columnSpan: 2
            anchors.top: parent.top
            width: 640
            height: 480
        }
        
        Row {
            id: rowSlider1
            anchors.left: parent.left
            anchors.top: videoItem.bottom
            anchors.margins: 10

            Label {
                text: "Threshold: " + slider1.value.toFixed(0)
                width: 120
            }

            Slider {
                id: slider1
                width: 300
                from: 0
                to: 255
                value: 50
                onValueChanged: videoItem.set_threshold(slider1.value)
            }
        }
        
        Row {
            id: rowSlider2
            anchors.left: parent.left
            anchors.top: rowSlider1.bottom
            anchors.margins: 10

            Label {
                text: "Smoothing: " + slider2.value.toFixed(0)
                width: 120
            }
            Slider {
                id: slider2
                width: 300
                from: 0
                to: 100
                value: 50
                onValueChanged: videoItem.set_smoothing(slider2.value)
            }
        }

        Row {
            id: rowSlider3
            anchors.top: rowSlider2.bottom
            anchors.left: parent.left
            anchors.margins: 10

            Label {
                text: "Update ms: " + slider3.value.toFixed(0)
                width: 120
            }
            Slider {
                id: slider3
                width: 300
                from: 0
                to: 1000
                value: 30
                onValueChanged: videoItem.set_speed(value)
            }
        }

        Row {
            id: rowSlider4
            anchors.top: rowSlider3.bottom
            anchors.left: parent.left
            anchors.margins: 10

            Label {
                text: "Mix spread: " + slider4.value.toFixed(0)
                width: 120
            }
            Slider {
                id: slider4
                width: 300
                from: 1
                to: 100
                value: 10
                onValueChanged: videoItem.set_sigma(value)
            }
        }

        TextField {
            id: textBox1
            anchors.top: videoItem.bottom
            anchors.right: parent.right
            anchors.margins: 10
            width: parent.width
            text: "/ALL/ping"
            placeholderText: "Enter OSC path"

            Layout.margins: 10

            Keys.onReturnPressed: {
                videoItem.set_manual_osc_path(textBox1.text)
            }
        }

        TextField {
            id: textBox2
            anchors.top: textBox1.bottom
            anchors.right: parent.right
            anchors.margins: 10
            width: parent.width
            placeholderText: "Enter OSC msg"
            text: "60,60,60"

            Layout.margins: 10

            Keys.onReturnPressed: {
                // Handle Enter key pressed event
                // console.log("Enter key pressed:", textBox2.text)
                videoItem.send_manual_osc(textBox1.text, textBox2.text)
            }
        }

        // Button
        // Button {
        //     id: toggleButton
        //     anchors.top: textBox2.bottom
        //     anchors.right: parent.right
        //     anchors.margins: 10
        //     text: "Toggle"
        //     onClicked: {
        //         // Handle button click event
        //         console.log("Button clicked")
        //         videoItem.toggle_mode()
        //     }
        // }
        CheckBox {
            id: chechbox0
            anchors.top: textBox2.bottom
            anchors.right: parent.right
            anchors.margins: 10

            checked: true
            text: qsTr("Send shifts")
            onClicked: {
                videoItem.set_sending_shifts(checked)
            }
        }

        RowLayout {
            id: checkboxRow1
            anchors.top: toggleButton.bottom
            anchors.left: parent.left
            anchors.margins: 10
            CheckBox {
                checked: false
                text: qsTr("Mod volume")
                onClicked: {
                    // console.log("Checkbox clicked:", text, checked)
                    videoItem.set_mod_volume(checked)
                }
            }
            CheckBox {
                checked: false
                text: qsTr("Pan override")
                onClicked: {
                    videoItem.set_pan_override(checked)
                }
            }
            CheckBox {
                checked: false
                text: qsTr("Cutoff override")
                onClicked: {
                    videoItem.set_cutoff_override(checked)
                }
            }
        }
        RowLayout {
            id: checkboxRow2
            anchors.top: checkboxRow1.bottom
            anchors.left: parent.left
            anchors.margins: 10
            CheckBox {
                checked: false
                text: qsTr("Auto circle panning")
                onClicked: {
                    videoItem.set_auto_circ_pan(checked)
                }
            }
            CheckBox {
                checked: false
                text: qsTr("Camera arp")
                onClicked: {
                    videoItem.set_camera_arp(checked)
                }
            }
        }

        // Rectangle {
        //     anchors.bottom: parent.bottom
        //     Layout.column: 0
        //     width: 640
        //     height: 400
        
        //     ChartView {
        //         id: chartView1
        //         title: "Line"
        //         anchors.fill: parent
        //         legend.alignment: Qt.AlignBottom
        //         antialiasing: true

        //         property var chartObject: chartData.getChart()

        //         Component.onCompleted: {
        //             // Set the chart as the main chart object
        //             chartView.chart = chartObject
        //         }

        //         onWidthChanged: chartObject.width = width
        //         onHeightChanged: chartObject.height = height
        //     }
        // }
    }
}
