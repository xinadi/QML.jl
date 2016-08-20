using Base.Test
using QML

# Test use of QTimer

bg_counter = 0

function counter_slot()
  global bg_counter
  bg_counter += 1
end

@qmlfunction counter_slot

timer = QTimer()

qmlfile = joinpath(dirname(@__FILE__), "qml", "qtimer.qml")
@qmlapp qmlfile timer
exec()

@test bg_counter > 100
