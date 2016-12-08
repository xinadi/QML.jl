ENV["QSG_RENDER_LOOP"] = "basic"
using CxxWrap # for safe_cfunction
using QML

qmlfile = joinpath(dirname(Base.source_path()), "qml", "gr.qml")

# Called from QQuickPaintedItem::paint with the QPainter as an argument
function paint(p)
  ENV["GKSconid"] = p
  return
end

# Convert to cfunction, passing the painter as void*
paint_cfunction = safe_cfunction(paint, Void, (Ptr{Void},))

# paint_cfunction becomes a context property
@qmlapp qmlfile paint_cfunction
exec()

@show ENV["GKSconid"]
"""
Template for GR.jl integration
"""
