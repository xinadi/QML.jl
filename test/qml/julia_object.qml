import QtQuick 2.0
import org.julialang 1.0

Timer {
     interval: 200; running: true; repeat: false
     onTriggered: {
       julia_object.a += parseInt("1")
       julia_object.b = 0
       Julia.test_string(julia_object.julia_string())
       Julia.jlobj_callback(julia_object)
       julia_object.i = Julia.innertwo()
       Julia.check_inner_x(julia_object.i.x)
       Qt.quit()
     }
 }
