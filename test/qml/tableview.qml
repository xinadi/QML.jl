import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels
import org.julialang

ApplicationWindow {
  title: "Arrays"
  width: 200
  height: 500
  visible: true

  TableView {
    anchors.fill: parent
    columnSpacing: 1
    rowSpacing: 1
    clip: true

    model: tablemodel

    delegate: Rectangle {
      implicitWidth: 100
      implicitHeight: 50
      Text {
        text: display
      }
    }
  }
}