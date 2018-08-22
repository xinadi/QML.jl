using Test
using QML

# absolute path in case working dir is overridden
qml_file = joinpath(dirname(@__FILE__), "qml", "qquickview.qml")

qview = init_qquickview()
ctx = root_context(QML.engine(qview))
ctxobj = QQmlPropertyMap(ctx)
set_context_object(ctx, ctxobj)
ctxobj["hi"] = "Hi from Julia"

# Load QML after setting context properties, to avoid errors
set_source(qview, qml_file)
QML.show(qview)

exec()
