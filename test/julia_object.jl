using Base.Test
using QML

# example type
type JuliaTestType
  a::Int32
end

# absolute path in case working dir is overridden
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "julia_object.qml")

julia_object = JuliaTestType(0.)

# Run with qml file and one context property
@qmlapp qml_file julia_object

# Run the application
QML.exec()

@test julia_object.a == 1
