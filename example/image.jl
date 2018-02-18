using Base.Test
using QML
using Images # for show of png
using TestImages

function test_display(d::JuliaDisplay)
  img = testimage("lena_color_256")
  display(d, img)
end

@qmlapp joinpath(dirname(@__FILE__), "qml", "image.qml")
@qmlfunction test_display

# Run the application
exec()
