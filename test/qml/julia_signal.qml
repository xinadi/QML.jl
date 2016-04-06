import QtQuick 2.0
import org.julialang 1.0

Item {
  JuliaSignals {
    signal testsignal()

    onTestsignal: Julia.call("println", ["test triggered"])
  }

  Timer {
       interval: 0; running: true; repeat: false
       onTriggered: {
         Julia.call("emit_signal")
         Qt.quit()
       }
   }
}
