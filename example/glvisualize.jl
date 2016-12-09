# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using CxxWrap
using QML
using QML.GLVisualizeSupport
using GLVisualize, GeometryTypes, GLAbstraction, Colors

# Cat example from GLVisualize
mesh 	= loadasset("cat.obj")

type CatAngle
  angle::Float64
end

const catangle = CatAngle(0)

# Render function that takes a parameter t from a QML slider
function render_function()
  rotation_angle = Float32(catangle.angle)*pi/180f0
  rotation  = rotationmatrix_x(deg2rad(90f0)) * rotationmatrix_y(rotation_angle)

  global context
  if(!isdefined(:context))
    context = visualize(mesh, model=rotation)
    _view(context)
    yield()
  end

  robj = context.children[1]
  robj.uniforms[:model] = rotation

  # The return here avoids a warning about the conversion of the rotation matrix to QML
  return
end

render_callback = CxxWrap.safe_cfunction(render_function, Void, ())

@qmlapp joinpath(dirname(@__FILE__), "qml", "glvisualize.qml") catangle render_callback
exec()
