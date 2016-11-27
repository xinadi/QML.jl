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
    interval: 500; running: true; repeat: false
    onTriggered: {

      decoratedlv.currentIndex = 0
      if(decoratedlv.currentItem.text != "---A---") {
        Julia.testfail("wrong value in decorated list: " + decoratedlv.currentItem.text)
      }

      lv.currentIndex = 0
      lv.currentItem.text = "TEST"

      Qt.quit()
    }
  }
}
