using QML

qml_file = Pkg.dir("QML", "example", "qml", "repl-background.qml")

@qmlfunction pushdisplay
@qmlapp qml_file
QML.exec_async()

ENV["MPLBACKEND"] = "Agg"
using Plots
pyplot(size=(512,512))
