using Base.Test
using QML

qml_file = joinpath(dirname(@__FILE__), "qml", "dynamiclist.qml")

qview = init_qquickview()

# Load QML after setting context properties, to avoid errors
set_source(qview, qml_file)
QML.show(qview)

# Run the application
exec()
