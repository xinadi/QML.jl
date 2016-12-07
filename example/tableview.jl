using Base.Test
using QML

type Nuclide
  name::String
  values::Vector{Float64}
end

years = [string(year) for year in 2016:2025] # exposed as context property
nuclides = [Nuclide(name, rand(length(years))) for name in ["Co60", "Cs137", "Ni63"]]

nuclidesModel = ListModel(nuclides)

# add year roles manually:
for (i,year) in enumerate(years)
  addrole(nuclidesModel, year, n -> round(n.values[i],2))
end

# Load QML after setting context properties, to avoid errors on initialization
qml_file = joinpath(dirname(@__FILE__), "qml", "tableview.qml")
@qmlapp qml_file years nuclidesModel

# Run the application
exec()
