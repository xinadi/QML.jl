import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

ApplicationWindow {
  title: "Arrays"
  width: 200
  height: 500
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

    Component
    {
      id: columnComponent
      TableViewColumn { width: 50 }
    }

    TableView {
      id: tabview
      width: 200
      height: 125
      model: tablemodel

      function setcolumns() {
        model = null
        while(columnCount != 0) {
          removeColumn(0);
        }
        for(var i=0; i < tablemodel.roles.length; i++) {
          var role  = tablemodel.roles[i];
          addColumn(columnComponent.createObject(tabview, { "role": role, "title": role}))
        }
        model = tablemodel
      }

      Connections {
        target: tablemodel
        onRolesChanged: tabview.setcolumns()
      }

      Component.onCompleted: setcolumns()
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

      if(tabview.columnCount != 3) {
        Julia.testfail("wrong column count: " + tabview.columnCount)
      }

      if(tabview.getColumn(0).role != "a") {
        Julia.testfail("Bad role name for a")
      }
      if(tabview.getColumn(1).role != "b") {
        Julia.testfail("Bad role name for b")
      }
      if(tabview.getColumn(2).role != "c") {
        Julia.testfail("Bad role name for c")
      }

      Julia.removerole_b()
      if(tabview.columnCount != 2) {
        Julia.testfail("wrong column count after remove 1: " + tabview.columnCount)
      }
      if(tabview.getColumn(0).role != "a") {
        Julia.testfail("Bad role name for a after remove 1")
      }
      if(tabview.getColumn(1).role != "c") {
        Julia.testfail("Bad role name for c after remove 1")
      }
      Julia.removerole_c()
      if(tabview.columnCount != 1) {
        Julia.testfail("wrong column count after remove: " + tabview.columnCount)
      }
      if(tabview.getColumn(0).role != "a") {
        Julia.testfail("Bad role name for a after remove 2")
      }

      Julia.setrole_a()
      if(tabview.columnCount != 1) {
        Julia.testfail("wrong column count after setrole: " + tabview.columnCount)
      }
      if(tabview.getColumn(0).role != "abc") {
        Julia.testfail("Bad role name for abc after setrow")
      }

      Qt.quit()
    }
  }
}
