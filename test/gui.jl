using Base.Test
using QML

hello() = "Hello from Julia"

counter = 0

function increment_counter()
  global counter
  global root_ctx
  @qmlset root_ctx.oldcounter = counter
  counter += 1
end

function counter_value()
  global counter
  return counter
end

bg_counter = 0

function counter_slot()
  global bg_counter
  global root_ctx
  bg_counter += 1
  @qmlset root_ctx.bg_counter = bg_counter
end

# absolute path in case working dir is overridden
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "main.qml")

app = QML.application()
qml_engine1 = QQmlApplicationEngine()

root_ctx = root_context(qml_engine1)
@qmlset root_ctx.oldcounter = counter

# Set up a timer
timer = QTimer()
@qmlset root_ctx.timer = timer
@qmlset root_ctx.bg_counter = bg_counter # initial value to avoid startup warning

# Load QML after setting context properties, to avoid errors
load(qml_engine1, qml_file)

# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)

println("Button was pressed $counter times")
println("Background counter now at $bg_counter")
