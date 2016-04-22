using Base.Test
using QML

hi = "Hi from Julia"

# absolute path in case working dir is overridden
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "qquickview.qml")

qview = init_qquickview()
@qmlset qmlcontext().hi = hi

# Load QML after setting context properties, to avoid errors
set_source(qview, qml_file)
QML.show(qview)

# Run the application
QML.exec()
