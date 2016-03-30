import QtQuick 2.0

Timer {
     interval: 0; running: true; repeat: false
     onTriggered: {
       julia_object.a = 1
       Qt.quit()
     }
 }
