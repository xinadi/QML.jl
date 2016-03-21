using BinDeps
@BinDeps.load_dependencies

using CppWrapper
wrap_modules(CppWrapper.lib_path(joinpath(Pkg.dir("QML"),"deps","usr","lib","libqml_wrapper")))
