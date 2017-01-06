import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.1
import QtQuick.Window 2.2

ApplicationWindow {
  title: "My Application"
  width: 800
  height: 600
  visible: true

  Component.onCompleted: {
    screeninfo.pixel_ratio = Screen.devicePixelRatio
  }

  ColumnLayout {
    id: root
    spacing: 6
    anchors.fill: parent

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignCenter

      Text {
        text: "Amplitude:"
      }

      Slider {
        id: amplitude
        width: 100
        value: 1.
        minimumValue: 0.1
        maximumValue: 5.
      }

      Text {
        text: "Frequency:"
      }

      Slider {
        id: frequency
        width: 100
        value: 1.
        minimumValue: 1.
        maximumValue: 50.
      }
    }

    JuliaPaintedItem {
      id: painter
      paintFunction : paint_cfunction
      Layout.fillWidth: true
      Layout.fillHeight: true

      Connections {
        target: amplitude
        onValueChanged: {
          sine_parameters.amplitude = amplitude.value;
          painter.update()
        }
      }

      Connections {
        target: frequency
        onValueChanged: {
          sine_parameters.frequency = frequency.value;
          painter.update()
        }
      }
    }
  }
}
