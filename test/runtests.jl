using Base.Test
using QML

hello() = "Hello from Julia"

counter = 0

function increment_counter()
  global counter
  counter += 1
end

function counter_value()
  global counter
  return counter
end

# absolute path in case working dir is overridden
qml_file = QString(joinpath(Pkg.dir("QML"), "test", "main.qml"))

app = QML.application()
e = QQmlApplicationEngine(qml_file)
QML.exec()

println("Button was pressed $counter times")
