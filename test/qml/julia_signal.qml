import QtQuick 2.0
import org.julialang 1.0

Item {

  JuliaSignals {
    signal testsignal()
    signal testsignalargs(real x, string s)

    onTestsignal: Julia.check1(true)
    onTestsignalargs: Julia.check2(x, s)
  }

  Timer {
       interval: 200; running: true; repeat: false
       onTriggered: {
         Julia.emit_signal1()
         Julia.emit_signal2()
         Qt.quit()
       }
   }
}
