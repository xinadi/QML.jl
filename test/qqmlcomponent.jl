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

app = QML.application()
qengine = QQmlEngine()
root_ctx = root_context(qengine)
set_context_property(root_ctx, "hi", hi)

qcomp = QQmlComponent(qengine)
set_data(qcomp, qml_data, "")
create(qcomp, root_ctx);

# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)
