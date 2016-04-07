import QtQuick 2.0
import org.julialang 1.0

Item {
  JuliaSignals {
    signal testsignal()
    signal testsignalargs(real x, string s)

    onTestsignal: Julia.call("check1", [true])
    onTestsignalargs: Julia.call("check2", [x, s])
  }

  Timer {
       interval: 0; running: true; repeat: false
       onTriggered: {
         Julia.call("emit_signal1")
         Julia.call("emit_signal2")
         Qt.quit()
       }
   }
}
