using QML

qml_file = joinpath(dirname(@__FILE__), "qml", "repl-background.qml")

@qmlfunction pushdisplay
@qmlapp qml_file
exec_async()

ENV["MPLBACKEND"] = "Agg"
using Plots
pyplot(size=(512,512))
