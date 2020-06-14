import QtQuick 2.0
import org.julialang 1.0

Item {
  Timer {
    interval: 200; running: true; repeat: false
    onTriggered: {
      Julia.julia_object_check(Julia.geta(objects.julia_object) == 1)
      Julia.julia_object_check(Julia.getx(objects.julia_object) == 2.0)
      objects.observed_object = Julia.replace_julia_object()
      Qt.quit()
    }
  }

  property var someNumber: Julia.getx(objects.observed_object)
  onSomeNumberChanged: Julia.logx(someNumber) // should be triggered when replacing observed_object
}
