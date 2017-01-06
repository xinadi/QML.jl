ENV["QSG_RENDER_LOOP"] = "basic"
using CxxWrap # for safe_cfunction
using QML
using GR

qmlfile = joinpath(dirname(Base.source_path()), "qml", "gr.qml")

type SineParameters
  amplitude::Float64
  frequency::Float64
end

sine_parameters = SineParameters(1,1)

type ScreenInfo
  pixel_ratio::Float64
end

const screeninfo = ScreenInfo(0.0)

# Called from QQuickPaintedItem::paint with the QPainter as an argument
function paint(p::QPainter, item::JuliaPaintedItem)
  println("pixel ratio: ", effectiveDevicePixelRatio(window(item)))
  ENV["GKSwstype"] = 381
  ENV["GKSconid"] = split(repr(p.cpp_object), "@")[2]

  x = 0:π/100:π
  f = sine_parameters.amplitude*sin(sine_parameters.frequency*x)

  dev = device(p)
  plt = gcf()
  plt[:size] = (width(dev), height(dev))

  plot(x,f)

  return
end

# Convert to cfunction, passing the painter as void*
paint_cfunction = safe_cfunction(paint, Void, (QPainter,JuliaPaintedItem))

# paint_cfunction becomes a context property
@qmlapp qmlfile paint_cfunction sine_parameters screeninfo
exec()

@show screeninfo.pixel_ratio

"""
Example of GR.jl integration
"""
