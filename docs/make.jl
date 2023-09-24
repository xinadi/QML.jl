using QML
using Documenter: deploydocs, makedocs

makedocs(sitename = "QML.jl", modules = [QML], doctest = false)
deploydocs(repo = "github.com/JuliaGraphics/QML.jl.git")
