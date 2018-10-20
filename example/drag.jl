using QML

@qmlfunction println
load(joinpath(dirname(@__FILE__), "qml", "drag.qml"))
exec()
