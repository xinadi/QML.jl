# MUST disable threading in Qt
ENV["QSG_RENDER_LOOP"] = "basic"

using QML
using GLVisualize, GeometryTypes, GLAbstraction, Colors

# Cat example from GLVisualize
mesh 	= loadasset("cat.obj")

# Render function that takes a parameter t from a QML slider
function render_callback(degrees)
  rotation_angle = Float32(degrees)*pi/180f0
  rotation  = rotationmatrix_x(deg2rad(90f0)) * rotationmatrix_y(rotation_angle)

  global robj
  if(!isdefined(:robj))
    robj = visualize(mesh, model=rotation)
    _view(robj)
  end

  set_arg!(robj, :model, rotation)
  #yield() # without this yield the rotation matrix is never updated
end

@qmlapp joinpath(dirname(@__FILE__), "qml", "glvisualize.qml")
exec()
