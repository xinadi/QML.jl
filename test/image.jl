using Base.Test
using QML
using TestImages

function test_display(d::JuliaDisplay)
  img = testimage("lena_color_256")
  display(d, img)
end

qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "image.qml")

@qmlapp qml_file
@qmlfunction test_display

# Run the application
QML.exec()
