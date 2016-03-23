using QML
"""
Example for using a mouse area and for implementing animations in QML.
"""

qml_file = joinpath(dirname(Base.source_path()), "qml", "tutorial.qml")

app = QML.application()
e = QQmlApplicationEngine(qml_file)
QML.exec()

return
