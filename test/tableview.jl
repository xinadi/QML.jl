using Test
using QML

# absolute path in case working dir is overridden
qml_file = joinpath(dirname(@__FILE__), "qml", "tableview.qml")

function testfail(message)
  println(message)
  exit(1)
end

julia_array = [1 2; 3 4; 5 6]
tablemodel = TableModel(julia_array)

@qmlfunction testfail
loadqml(qml_file, tablemodel=tablemodel)

exec()
