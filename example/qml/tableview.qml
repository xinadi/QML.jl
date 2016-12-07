import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.julialang 1.0

// Dynamic columns idea from:
// http://stackoverflow.com/questions/27230818/qml-tableview-with-dynamic-number-of-columns

ApplicationWindow {
  title: "Arrays"
  width: 800
  height: 400
  visible: true

  Component
  {
    id: columnComponent
    TableViewColumn { width: 50 }
  }

  TableView {
    id: view
    anchors.fill: parent
    model: nuclidesModel

    resources:
    {
      var columns = []
      columns.push(columnComponent.createObject(view, { "role": "name", "title": "Nuclide", "width": 100 }))
      for(var i=0; i<years.length; i++)
      {
        var role  = years[i]
        columns.push(columnComponent.createObject(view, { "role": role, "title": role}))
      }
      return columns
    }
  }
}
