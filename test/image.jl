using Base.Test
using QML
using TestImages

function test_display(d::JuliaDisplay)
  img = testimage("lena_color_256")
  display(d, img)
end

@qmlfunction test_display

qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "image.qml")

app = QML.application()
qml_engine4 = QQmlApplicationEngine()

# Load QML after setting context properties, to avoid errors
load(qml_engine4, qml_file)

# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)
