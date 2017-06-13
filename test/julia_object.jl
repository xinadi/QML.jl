using Base.Test
using QML

type InnerType
  x::Float64
end

# example type
type JuliaTestType
  a::Int32
  i::InnerType
end

# absolute path in case working dir is overridden
qml_file = joinpath(dirname(@__FILE__), "qml", "julia_object.qml")

julia_object = JuliaTestType(0, InnerType(0.0))
julia_object2 = JuliaTestType(0, InnerType(0.0))

function test_string(s)
  try
    @test s == "JuliaTestType(1, InnerType(0.0))"
    return
  catch e
    exit(1)
  end
end

function jlobj_callback(o::JuliaTestType)
  try
    @test o == julia_object
    return
  catch e
    exit(1)
  end
end

innertwo() = InnerType(2.0)

function check_inner_x(x)
  try
    @test x == 2.0
    return
  catch e
    exit(1)
  end
end

function setthree(x::JuliaTestType)
  x.a = 3
  x.i.x = 3.0
end

function testthree(a,x)
  try
    @test a == 3
    @test x == 3.0
  catch
    exit(1)
  end
end

@qmlfunction test_string jlobj_callback innertwo check_inner_x setthree testthree

# Run with qml file and one context property
@qmlapp qml_file julia_object julia_object2

@test (@qmlget qmlcontext().julia_object.a) == 0
@test (@qmlget qmlcontext().julia_object.i.x) == 0.0
@test QML.julia_value(@qmlget qmlcontext().julia_object).a == 0

# Run the application
exec()


@test julia_object.a == 1
@test julia_object.i.x == 2.0
