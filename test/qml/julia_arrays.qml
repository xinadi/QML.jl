import QtQuick 2.0
import org.julialang 1.0

Timer {
     interval: 0; running: true; repeat: false
     onTriggered: {
       var a = Julia.get_array()
       Julia.verify_array(a)
       Julia.verify_array(julia_array)
       Qt.quit()
     }
 }
