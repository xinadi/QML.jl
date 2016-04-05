import QtQuick 2.0
import org.julialang 1.0

Item {

  JuliaSignals {
    id: mysigs
    signal testsignal()
    onTestsignal: console.log("Test emitted")
  }

  Timer {
       interval: 0; running: true; repeat: false
       onTriggered: {
         //Julia.call("emit_signal")
         mysigs.testsignal()
         Qt.quit()
       }
   }
}
