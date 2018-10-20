import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
  id: root
  title: "Observables"
  width: 512
  height: 200
  visible: true
  onClosing: Qt.quit()

  ColumnLayout {
    spacing: 6
    anchors.fill: parent

    Slider {
      value: input
      Layout.alignment: Qt.AlignCenter
      Layout.fillWidth: true
      minimumValue: 0.0
      maximumValue: 100.0
      stepSize: 1.0
      tickmarksEnabled: true
      onValueChanged: {
        input = value;
        output = 2*input;
      }
    }

    Text {
      Layout.alignment: Qt.AlignCenter
      text: output
      font.pixelSize: 0.1*root.height
    }
  }

}
