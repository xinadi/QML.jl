using QML

# Encapsulate a point position
type Point
  x::Float64
  y::Float64
end

const position = Point(0,0)

qmlfile = joinpath(dirname(Base.source_path()), "qml", "sketch.qml")
# Load the QML file, using position as a context property
@qmlapp qmlfile position
exec()

# Confirm that the point position is exposed to Julia
println("Last position: ", position)

"""
Example for sketching on a canvas
"""
