import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

Item {

  function verify_array(a) {
    if(a[0] != "A" || a[1] != 1 || a[2] != 2.2)
    {
      console.log("Bad array: ", a)
      throw "Error verifying array"
    }
  }

  Timer {
    interval: 200; running: true; repeat: false
    onTriggered: {
      var a = Julia.get_array()
      verify_array(a)
      verify_array(julia_array)

      if(int_array[0] != 1 || int_array[1] != 2 || int_array[2] != 3) {
        console.log("Bad int array: ", int_array)
        throw "Error verifying int array"
      }

      ob_array = [7,8,9]

      array_model2.setProperty(2, "myrole", "TEST2")
      array_model2.append({"myrole":"Added"})
      array_model2.append({"myrole":2})
      array_model2.append({"myrole":2})
      array_model2.setProperty(5, "myrole", 3)

      array_model2.remove(1)

      move_model.move(2,5,3)

      resize_typed_model.remove(2)
      resize_typed_model.move(3,0,1)

      insert_model.insert(2,[3])

      clear_model.clear()

      custom_model.setProperty(1, "b", 5)
      custom_model.append({"b":10, "a":"ten"})

      Qt.quit()
    }
  }
}
