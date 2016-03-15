using Base.Test
using QML

my_one() = 1

app = QML.application()
e = QML.QQmlApplicationEngine(QML.QString("main.qml"))
QML.exec()
