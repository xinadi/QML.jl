using Test
using QML
using Observables

# absolute path in case working dir is overridden
qml_file = joinpath(dirname(@__FILE__), "qml", "qml_propertymap.qml")

function propertymap_test(b)
  @test b
  return
end

expected_ob = 2

function set_expected_ob(x)
  global expected_ob
  expected_ob = x
  return
end

function do_ob_update(x)
  set_expected_ob(x)
  global ob
  ob[] = x
end

@qmlfunction propertymap_test set_expected_ob do_ob_update

propmap = QML.QQmlPropertyMap()
propmap["a"] = 1
@test propmap["a"] == 1

ob = Observable(expected_ob)
propmap["ob"] = ob

ob_handler_calls = 0

on(ob) do x
  global ob_handler_calls
  ob_handler_calls += 1
  @test x == expected_ob
end

expected_ob = 3
println("setting ob from Julia to value $expected_ob")
ob[] = expected_ob

@test propmap["ob"] == expected_ob

# Load the QML file, setting the property map as context object
load(qml_file, propmap)

# Run the application
exec()

@test ob[] == expected_ob
@test ob_handler_calls == 3