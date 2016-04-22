using Base.Test
using QML

hello() = "Hello from Julia"

counter = 0

function increment_counter()
  global counter
  @qmlset qmlcontext().oldcounter = counter
  counter += 1
end

function counter_value()
  global counter
  return counter
end

bg_counter = 0

function counter_slot()
  global bg_counter
  bg_counter += 1
  @qmlset qmlcontext().bg_counter = bg_counter
end

@qmlfunction counter_slot hello increment_counter uppercase string

# absolute path in case working dir is overridden
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "main.qml")

# Initialize app and engine. Lifetime managed by C++
qml_engine = init_qmlapplicationengine()

# Set up a timer
timer = QTimer()

# Set context properties
@qmlset qmlcontext().oldcounter = counter
@qmlset qmlcontext().bg_counter = bg_counter
@qmlset qmlcontext().timer = timer

# Load the QML file
load(qml_engine, qml_file)

# Run the application
QML.exec()

println("Button was pressed $counter times")
println("Background counter now at $bg_counter")
