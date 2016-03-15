using BinDeps
@BinDeps.load_dependencies

using CppWrapper
wrap_modules(joinpath(Pkg.dir("QML"),"deps","usr","lib","libqml_wrapper"))
