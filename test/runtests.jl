using Base.Test
using QML

app = QML.application()
e = QML.QQmlApplicationEngine(QML.QString("main.qml"))
QML.exec()
