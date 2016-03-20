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

bg_counter = 0
run_counter = false

function counter_slot()
  global bg_counter
  global run_counter
  global root_ctx
  bg_counter += 1
  set_context_property(root_ctx, "bg_counter", bg_counter)
end

# absolute path in case working dir is overridden
qml_file = QString(joinpath(Pkg.dir("QML"), "test", "main.qml"))

app = QML.application()
qml_engine = QQmlApplicationEngine(qml_file)
root_ctx = root_context(qml_engine)
set_context_property(root_ctx, "oldcounter", counter)

# Set up a timer
timer = QTimer() # important to keep timer variable, to avoid deletion upon GC
cslot_obj = JuliaSlot(counter_slot)
connect_timeout(timer, cslot_obj)
set_context_property(root_ctx, "timer", timer)

# Run the application
QML.exec()

println("Button was pressed $counter times")
println("Background counter now at $bg_counter")
