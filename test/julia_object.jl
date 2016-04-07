using Base.Test
using QML

# example type
type JuliaTestType
  a::Int32
end

# absolute path in case working dir is overridden
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "julia_object.qml")

app = QML.application()
qml_engine2 = QQmlApplicationEngine()
root_ctx = root_context(qml_engine2)

jobj = JuliaTestType(0.)
@qmlset root_ctx.julia_object = jobj

# Load QML after setting context properties, to avoid errors
load(qml_engine2, qml_file)

# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)

@test jobj.a == 1
@test @qmlget(root_ctx.julia_object.a) == 1
@qmlset root_ctx.julia_object.a = 2
@test @qmlget(root_ctx.julia_object.a) == 2
