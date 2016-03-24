using Base.Test
using QML

hi = "Hi from Julia"

# absolute path in case working dir is overridden
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "qquickview.qml")

app = QML.application()
qview = QQuickView()
qengine = engine(qview)
root_ctx = root_context(qengine)
set_context_property(root_ctx, "hi", hi)

# Load QML after setting context properties, to avoid errors
set_source(qview, qml_file)
QML.show(qview)

# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)
