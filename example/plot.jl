using Base.Test
using QML
using Plots

# No Python gui:
ENV["MPLBACKEND"] = "Agg"

oldwidth = 0
oldheight = 0

function plotsin(d::JuliaDisplay, width::Float64, height::Float64, amplitude::Float64, frequency::Float64)
  if width < 5 || height < 5
    return
  end

  global oldwidth
  global oldheight

  if oldwidth != width || oldheight != height
    pyplot(size=(Int64(round(width)),Int64(round(height))))
    oldwidth = width
    oldheight = height
  end

  x = 0:π/100:π
  f = amplitude*sin(frequency*x)

  display(d, plot(x,f))
  close()
end

@qmlfunction plotsin

qml_file = joinpath(Pkg.dir("QML"), "example", "qml", "plot.qml")

app = QML.application()
qml_engine4 = QQmlApplicationEngine()

# Load QML after setting context properties, to avoid errors
load(qml_engine4, qml_file)

# Run the application
QML.exec()

# Needed to prevent crash-on-exit (order of finalization matters)
finalize(qml_engine4)
finalize(app)
