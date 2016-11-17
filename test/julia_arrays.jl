using Base.Test
using QML

# absolute path in case working dir is overridden
qml_file = joinpath(dirname(@__FILE__), "qml", "julia_arrays.qml")

julia_array = ["A", 1, 2.2]
move_array = collect(0:9)
resize_typed_array = collect(1:5)
insert_array = [1,2,4]
clear_array = [1.,2.]

function verify_array(a)
  @test a[1] == "A"
  @test a[2] == 1
  @test a[3] == 2.2
  return
end

function testfail(message)
  println(message)
  exit(1)
end

get_array() = julia_array

myrole(x::AbstractString) = lowercase(x)
myrole(x::Number) = Int(round(x))
decorated(x) = "---" * string(x) * "---"

array_model = ListModel(julia_array)
array_model2 = ListModel(julia_array)
move_model = ListModel(move_array)
resize_typed_model = ListModel(resize_typed_array)
insert_model = ListModel(insert_array)
clear_model = ListModel(clear_array)

setrolenames(array_model2, ["myrole", "decorated"])
setconstructor(array_model2, "identity")
setconstructor(insert_model, "identity")

@qmlfunction get_array verify_array testfail
@qmlapp qml_file julia_array array_model array_model2 move_model resize_typed_model insert_model clear_model

# Run the application
exec()

@show julia_array
@show move_array

@test length(julia_array) == 5
@test julia_array[1] == "test"
@test julia_array[2] == "test2"
@test julia_array[3] == "Added"
@test julia_array[4] == 2
@test typeof(julia_array[4]) == Int32
@test julia_array[5] == 3
@test typeof(julia_array[5]) == Int # Due to passing through the myrole function
@test move_array == [0,1,5,6,7,2,3,4,8,9]
@test typeof(move_array) == Array{Int,1}
@test resize_typed_array == [5,1,2,4]
@test typeof(resize_typed_array) == Array{Int,1}
@test insert_array == [1,2,3,4]
@test isempty(clear_array)
