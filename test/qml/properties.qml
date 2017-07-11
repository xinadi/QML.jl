import QtQuick 2.0
import org.julialang 1.0

Item {

  Timer {
    interval: 200; running: true; repeat: false
    onTriggered: {
      Julia.check_property(my_prop)
      Julia.check_golden(φ == 1.618033988749895)
      Qt.quit()
    }
  }
}
