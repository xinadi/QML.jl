using Base.Test
using QML

# absolute path in case working dir is overridden
qml_file = joinpath(dirname(@__FILE__), "qml", "listviews.qml")

julia_array = ["A", 1, 2.2]

function testfail(message)
  println(message)
  exit(1)
end

myrole2(x::AbstractString) = lowercase(x)
myrole2(x::Number) = Int(round(x))
decorated2(x) = "---" * string(x) * "---"

array_model = ListModel(julia_array)
array_model2 = ListModel(julia_array)
addrole(array_model2, "myrole", myrole2, setindex!)
addrole(array_model2, "decorated", decorated2)
setconstructor(array_model2, identity)

@qmlfunction testfail
@qmlapp qml_file array_model array_model2

exec()

@show julia_array

@test julia_array[1] == "TEST"
