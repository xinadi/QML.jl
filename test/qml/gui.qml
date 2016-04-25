import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    title: "My Application"
    width: 480
    height: 640
    visible: true

    Connections {
      target: timer
      onTimeout: Julia.counter_slot()
    }

    ColumnLayout {
      spacing: 6
      anchors.centerIn: parent

      Text {
          id: juliaHello
          Layout.alignment: Qt.AlignCenter
          text: Julia.hello()
      }

      Button {
          Layout.alignment: Qt.AlignCenter
          text: "Push Me"
          onClicked: { resultDisplay.text = Julia.increment_counter().toString() }
      }

      Text {
          id: resultDisplay
          Layout.alignment: Qt.AlignCenter
          text: "Push button for result"
      }

      TextField {
          id: lowerIn
          Layout.alignment: Qt.AlignCenter
          Layout.minimumWidth: 300
          placeholderText: qsTr("Start typing, Julia does the rest...")
      }

      Text {
          id: upperOut
          Layout.alignment: Qt.AlignCenter
          text: Julia.uppercase(lowerIn.text)
      }

      Text {
          Layout.alignment: Qt.AlignCenter
          text: "Concatenation, showing multiple arguments:"
      }

      Text {
          Layout.alignment: Qt.AlignCenter
          text: Julia.string(oldcounter, ", ", upperOut.text)
      }

      Button {
          Layout.alignment: Qt.AlignCenter
          text: "Start counting"
          onClicked: timer.start()
      }

      Text {
          Layout.alignment: Qt.AlignCenter
          text: bg_counter.toString()
      }

      Button {
          Layout.alignment: Qt.AlignCenter
          text: "Stop counting"
          onClicked: timer.stop()
      }
  }
}
