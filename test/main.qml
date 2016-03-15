import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.2
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
          onClicked: { resultDisplay.text = julia.call("my_one").toString() }
      }

      Text {
          id: resultDisplay
          Layout.alignment: Qt.AlignCenter
          text: "Push button for result"
      }
  }
}
