using Base.Test
using QML

hello() = "Hello from Julia"

counter = 0

function increment_counter()
  global counter
  global root_ctx
  set_context_property(root_ctx, "oldcounter", counter)
  counter += 1
end

function counter_value()
  global counter
  return counter
end

# absolute path in case working dir is overridden
qml_file = QString(joinpath(Pkg.dir("QML"), "test", "main.qml"))

app = QML.application()
qml_engine = QQmlApplicationEngine(qml_file)
root_ctx = root_context(qml_engine)
set_context_property(root_ctx, "oldcounter", counter) # avoids undefined reference at startup
QML.exec()

println("Button was pressed $counter times")
