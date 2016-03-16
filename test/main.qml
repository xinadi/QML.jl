import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
    title: "My Application"
    width: 640
    height: 480
    visible: true

    JuliaContext {
      id: julia
    }

    ColumnLayout {
      spacing: 2
      anchors.centerIn: parent

      Button {
          Layout.alignment: Qt.AlignCenter
          text: "Push Me"
          onClicked: { resultDisplay.text = julia.call("increment_counter").toString() }
      }

      Text {
          id: resultDisplay
          Layout.alignment: Qt.AlignCenter
          text: "Push button for result"
      }
  }
}
