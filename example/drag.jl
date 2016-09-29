using QML

@qmlfunction println
@qmlapp joinpath(dirname(@__FILE__), "qml", "drag.qml")
exec()
