using Base.Test
using QML

function emit_signal1()
  @emit testsignal()
end

function emit_signal2()
  @emit testsignalargs(2., "Hi from Julia")
end

function check1(result::Bool)
  @test result
  nothing
end

function check2(x::Float64, s::AbstractString)
  @test x == 2.
  @test s == "Hi from Julia"
  nothing
end

@qmlfunction emit_signal1
@qmlfunction emit_signal2
@qmlfunction check1 check2

# absolute path in case working dir is overridden
qml_file = Pkg.dir("QML", "test", "qml", "julia_signal.qml")

app = QML.application()
qml_engine3 = QQmlApplicationEngine()
root_ctx = root_context(qml_engine3)

# Load QML after setting context properties, to avoid errors
load(qml_engine3, qml_file)

# Run the application
QML.exec()

# Needed to prevent crash-on-exit
finalize(app)
