import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.1

ApplicationWindow {
  title: "GR"
  width: 200
  height: 200
  visible: true

  JuliaPaintedItem {
    anchors.fill: parent
    paintFunction: paint_cfunction
  }
}
