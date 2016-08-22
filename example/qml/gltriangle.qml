import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
  title: "My Application"
  width: 512
  height: 512
  visible: true

  ColumnLayout {
    id: root
    spacing: 6
    anchors.fill: parent

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignCenter

      Text {
        text: "X min:"
      }

      Slider {
        id: xmin
        value: -0.5
        minimumValue: -1.
        maximumValue: 0.
      }

      Text {
        text: "X max:"
      }

      Slider {
        id: xmax
        value: 0.5
        minimumValue: 0.
        maximumValue: 1.
      }
    }

    OpenGLViewport {
      id: jvp
      Layout.fillWidth: true
      Layout.fillHeight: true
      renderFunction: "render"
      renderArguments: [xmin.value, xmax.value]
    }
  }

}
