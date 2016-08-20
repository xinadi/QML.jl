using Base.Test
using QML

# Test context properties

function check_property(x)
  @test x == @qmlget qmlcontext().my_prop
  nothing
end

@qmlfunction check_property
qmlfile = joinpath(dirname(@__FILE__), "qml", "properties.qml")

my_prop = 1
@qmlapp qmlfile my_prop
exec()
