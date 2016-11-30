import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Timer {
  interval: 10; running: true; repeat: false
  onTriggered: {
    Qt.quit()
  }
}
