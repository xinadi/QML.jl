using Base.Test
using QML

# Test context properties

propmap = QQmlPropertyMap()
propmap["my_prop"] = 1
propmap["φ"] = φ

function check_property(x)
  @test x == propmap["my_prop"]
  nothing
end

function check_golden(golden_constant_match)
  @test golden_constant_match
  nothing
end

@qmlfunction check_property check_golden
qmlfile = joinpath(dirname(@__FILE__), "qml", "properties.qml")

load(qmlfile, propmap)
exec()
