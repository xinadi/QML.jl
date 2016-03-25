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
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "main.qml")

app = QML.application()
qml_engine = QQmlApplicationEngine()

root_ctx = root_context(qml_engine)
jctx = JuliaContext()
set_context_property(root_ctx, "julia", jctx)
set_context_property(root_ctx, "oldcounter", counter)

# Set up a timer
timer = QTimer() # important to keep timer variable, to avoid deletion upon GC
cslot_obj = JuliaSlot(counter_slot)
connect_timeout(timer, cslot_obj)
set_context_property(root_ctx, "timer", timer)
set_context_property(root_ctx, "bg_counter", bg_counter) # initial value to avoid startup warning

# Load QML after setting context properties, to avoid errors
load(qml_engine, qml_file)

# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)

println("Button was pressed $counter times")
println("Background counter now at $bg_counter")
