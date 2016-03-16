using Base.Test
using QML

counter = 0

function increment_counter()
  global counter
  counter += 1
end

app = QML.application()
e = QQmlApplicationEngine(QString("main.qml"))
QML.exec()

println("Button was pressed $counter times")
