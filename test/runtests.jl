using Base.Test
using QML

counter = 0

function increment_counter()
  global counter
  counter += 1
end

app = QML.application()
e = QML.QQmlApplicationEngine(QML.QString("main.qml"))
QML.exec()

println("Button was pressed $counter times")
