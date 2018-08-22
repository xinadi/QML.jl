using Test
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

function append_year()
  global years
  global nuclides
  global nuclidesModel
  newyear = length(years) > 0 ? string(parse(Int, years[end])+1) : "2016"
  push!(years, newyear)
  for nuc in nuclides
    push!(nuc.values, rand())
  end
  @qmlset qmlcontext().years = years
  year_idx = length(years)
  addrole(nuclidesModel, newyear, n -> round(n.values[year_idx],2))
end

function pop_year_front()
  global years
  global nuclides
  global nuclidesModel
  if isempty(years)
    return
  end
  removed_year = shift!(years)
  # Updating the values is not strictly necessary, but if we do we must update the getter functions to use the new indices
  for nuc in nuclides
    shift!(nuc.values)
  end
  for (i,year) in enumerate(years)
    setrole(nuclidesModel, i+2, year, n -> round(n.values[i],2))
  end
  @qmlset qmlcontext().years = years
  removerole(nuclidesModel, removed_year)
end

@qmlfunction append_year pop_year_front

# Load QML after setting context properties, to avoid errors on initialization
qml_file = joinpath(dirname(@__FILE__), "qml", "tableview.qml")
@qmlapp qml_file years nuclidesModel

# Run the application
exec()
