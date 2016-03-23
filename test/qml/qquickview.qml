import QtQuick 2.0

Rectangle {
  width: 100; height: 100; color: "red"

  Text {
    anchors.centerIn: parent
    text: hi // Context property set from Julia
  }
}
