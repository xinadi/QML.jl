using Base.Test
using QML

# absolute path in case working dir is overridden
qml_file = joinpath(dirname(@__FILE__), "qml", "julia_arrays.qml")

julia_array = ["a", 1, 2.]

function verify_array(a)
  @test a[1] == "a"
  @test a[2] == 1
  @test a[3] == 2.
  return
end

get_array() = julia_array

# Run with qml file and one context property
@qmlfunction get_array verify_array
@qmlapp qml_file julia_array

# Run the application
exec()
