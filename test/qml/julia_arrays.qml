import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
  title: "Arrays"
  width: 200
  height: 375
  visible: true

  ColumnLayout {
    id: root
    spacing: 6
    anchors.fill: parent

    ListView {
      width: 200
      height: 125
      model: array_model
      delegate: Text { text: string }
    }

    ListView {
      id: decoratedlv
      width: 200
      height: 125
      model: array_model2
      delegate: Text {
        text: decorated
      }
    }

    ListView {
      id: lv
      width: 200
      height: 125
      model: array_model2
      delegate: TextField {
        placeholderText: myrole.toString()
        onTextChanged: myrole = text
      }
    }
  }

  Timer {
    interval: 1500; running: true; repeat: false
    onTriggered: {
      var a = Julia.get_array()
      Julia.verify_array(a)
      Julia.verify_array(julia_array)

      decoratedlv.currentIndex = 0
      if(decoratedlv.currentItem.text != "---A---") {
        Julia.testfail("wrong value in decorated list: " + decoratedlv.currentItem.text)
      }

      lv.currentIndex = 0
      lv.currentItem.text = "TEST"

      array_model2.setData(array_model2.index(2,0),"TEST2", array_model2.myrole)
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

      Qt.quit()
    }
  }
}
