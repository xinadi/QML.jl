using QML
try
    @qmlapp joinpath(dirname(@__FILE__), "qml", "badqml.qml")
    exec()
catch e
    @test e.msg == "Error loading QML"
end