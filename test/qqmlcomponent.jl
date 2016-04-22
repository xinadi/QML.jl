using Base.Test
using QML

hi = "Hi from Julia"

# absolute path in case working dir is overridden
qml_data = QByteArray("""
import QtQuick 2.0
import QtQuick.Controls 1.0

ApplicationWindow {
  title: "My Application"
  width: 100
  height: 100
  visible: true

  Rectangle {
    width: 100; height: 100; color: "red"

    Text {
      anchors.centerIn: parent
      text: hi // Context property set from Julia
    }
  }
}
""")

qengine = init_qmlengine()
@qmlset qmlcontext().hi = hi

qcomp = QQmlComponent(qengine)
set_data(qcomp, qml_data, "")
create(qcomp, qmlcontext());

# Run the application
QML.exec()
