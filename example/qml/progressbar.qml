import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
  title: "My Application"
  width: 480
  height: 200
  visible: true

  // Set up timer connection
  Connections {
    target: timer
    onTimeout: ticks += 1
  }

  ColumnLayout {
    spacing: 6
    anchors.centerIn: parent

    ComboBox {
      Layout.alignment: Qt.AlignCenter
      currentIndex: selectedSimType-1
      model: simulationTypes
      width: 300
      onCurrentIndexChanged: selectedSimType = currentIndex+1
    }

    RowLayout {
      Layout.alignment: Qt.AlignCenter
      Text { text: "Step size (ms)" }
      Slider {
        from: 0
        value: stepsize
        stepSize: 1
        to: 100
        onValueChanged: stepsize = value
      }
      Text { text: stepsize }
    }

    ProgressBar {
      Layout.alignment: Qt.AlignCenter
      value: progress
    }

    Button {
      Layout.alignment: Qt.AlignCenter
      text: "Start simulation"
      onClicked: {
        timer.start();
      }
    }

    Button {
      Layout.alignment: Qt.AlignCenter
      text: "Stop simulation"
      onClicked: timer.stop();
    }
  }
}
