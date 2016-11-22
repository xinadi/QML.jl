import QtQuick 2.0
import org.julialang 1.0

Item {

  JuliaDisplay {
    id: jdisp
  }

  Timer {
    interval: 200; running: true; repeat: false
    onTriggered: {
      Julia.julia_callback1(false)
      Julia.julia_callback1(1)
      Julia.julia_callback1(1.5)
      Julia.julia_callback1("test")
      Julia.julia_callback1(jdisp)

      Julia.julia_callback2(1.5, 2.)
      Julia.julia_callback2(2, 3)
      Julia.julia_callback2("a", "b")

      Julia.check_return_callback(Julia.return_callback())

      Julia.test_qvariant_map({"somekey": "somevalue"})

      Qt.quit()
    }
  }
}
