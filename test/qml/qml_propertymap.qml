import QtQuick 2.0
import org.julialang 1.0

Timer {
     interval: 200; running: true; repeat: false
     onTriggered: {
      Julia.propertymap_test(a == 1)
      Julia.propertymap_test(ob == 3)

      Julia.set_expected_ob(5)
      console.log("Setting Observable from QML to 5")
      ob = 5;
      Julia.propertymap_test(ob == 5)

      console.log("Requesting update from Julia for value 4")
      Julia.do_ob_update(4)
      Julia.propertymap_test(ob == 4)

      Qt.quit();
     }
 }
