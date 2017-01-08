import QtQuick 2.0
import QtQuick.Controls 1.0
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
    onTimeout: Julia.step()
  }

  ColumnLayout {
    spacing: 6
    anchors.centerIn: parent

    ProgressBar {
      value: simulation_state.progress
      onValueChanged: {
        if(value >= 1.0) {
          timer.stop()
        }
      }
    }

    Button {
      Layout.alignment: Qt.AlignCenter
      text: "Start simulation"
      onClicked: timer.start()
    }

    Button {
      Layout.alignment: Qt.AlignCenter
      text: "Stop simulation"
      onClicked: timer.stop()
    }
  }
}
