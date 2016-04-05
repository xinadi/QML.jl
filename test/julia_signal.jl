using Base.Test
using QML

function emit_signal()
  emit("testsignal", [])
end

# absolute path in case working dir is overridden
qml_file = joinpath(Pkg.dir("QML"), "test", "qml", "julia_signal.qml")

app = QML.application()
qml_engine = QQmlApplicationEngine()
root_ctx = root_context(qml_engine)

# Load QML after setting context properties, to avoid errors
load(qml_engine, qml_file)
# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)
