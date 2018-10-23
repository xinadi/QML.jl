using Test
using QML
using Observables

struct Nuclide
  name::String
  values::Dict{Int,Float64}
end

const years = Observable(collect(2016:2025)) # exposed as context property
nuclides = [Nuclide(name, Dict([(y,rand()) for y in years[]])) for name in ["Co60", "Cs137", "Ni63"]]
nuclidesModel = ListModel(nuclides)

add_year_role(model, year) = addrole(model, string(year), n -> round(n.values[year]; digits=2))

# add year roles manually:
for y in years[]
  add_year_role(nuclidesModel, y)
end

on(years) do ys
  ys_int = Int.(ys)
  roleints = parse.(Int,roles(nuclidesModel)[3:end])
  addyears!(nuclidesModel, nuclides, setdiff(ys_int, roleints))
  delyears!(nuclidesModel, nuclides, setdiff(roleints, ys_int))
end

function addyears!(model, nuclides, years)
  for y in years
    for nuc in nuclides
      nuc.values[y] = rand()
    end
    add_year_role(model, y)
  end
end

function delyears!(model, nuclides, years)
  for y in years
    for nuc in nuclides
      delete!(nuc.values, y)
    end
    removerole(model, string(y))
  end
end

# Load QML after setting context properties, to avoid errors on initialization
qml_file = joinpath(dirname(@__FILE__), "qml", "tableview.qml")
load(qml_file, years=years, nuclidesModel=nuclidesModel)

# Run the application
exec()
