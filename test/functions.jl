using Base.Test
using QML
using Compat

# Test calling Julia functions

call_results1 = []

function julia_callback1(x)
  global call_results1
  push!(call_results1, x)
  nothing
end

call_results2 = []

function julia_callback2(x, y)
  global call_results2
  push!(call_results2, x*y)
  nothing
end

return_callback() = Int32(5)

function check_return_callback(x::Int32)
  @test x == 5
  nothing
end

@qmlfunction julia_callback1 julia_callback2 return_callback check_return_callback
@qmlapp joinpath(dirname(@__FILE__), "qml", "functions.qml")
exec()

stringresult = VERSION < v"0.5-dev" ? ASCIIString : String

@test typeof(call_results1[1]) == Bool
@test typeof(call_results1[2]) == Int32
@test typeof(call_results1[3]) == Float64
@test typeof(call_results1[4]) == stringresult
@test typeof(call_results1[5]) == QML.JuliaDisplay
@test call_results1[1:4] == [false, 1, 1.5, "test"]

@test typeof(call_results2[1]) == Float64
@test typeof(call_results2[2]) == Int32
@test typeof(call_results2[3]) == stringresult
@test call_results2 == [3., 6, "ab"]
