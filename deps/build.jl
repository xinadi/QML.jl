using BinDeps
using CxxWrap

@windows_only push!(BinDeps.defaults, SimpleBuild)
@BinDeps.setup

cxx_wrap_dir = joinpath(Pkg.dir("CxxWrap"),"deps","usr","lib","cmake")

qmlwrap = library_dependency("qmlwrap", aliases=["libqmlwrap"])
prefix=joinpath(BinDeps.depsdir(qmlwrap),"usr")
qmlwrap_srcdir = joinpath(BinDeps.depsdir(qmlwrap),"src","qmlwrap")
qmlwrap_builddir = joinpath(BinDeps.depsdir(qmlwrap),"builds","qmlwrap")
lib_prefix = @windows ? "" : "lib"
lib_suffix = @windows? "dll" : (@osx? "dylib" : "so")

# Set generator if on windows
genopt = "Unix Makefiles"
@windows_only begin
  if WORD_SIZE == 64
    genopt = "Visual Studio 14 2015 Win64"
  else
    genopt = "Visual Studio 14 2015"
  end
end

provides(BuildProcess,
  (@build_steps begin
    CreateDirectory(qmlwrap_builddir)
    @build_steps begin
      ChangeDirectory(qmlwrap_builddir)
      FileRule(joinpath(prefix,"lib", "$(lib_prefix)qmlwrap.$lib_suffix"),@build_steps begin
        `cmake -G "$genopt" -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_BUILD_TYPE="Release" -DCxxWrap_DIR="$cxx_wrap_dir" $qmlwrap_srcdir`
        `cmake --build . --config Release --target install`
      end)
    end
  end),qmlwrap)

deps = [qmlwrap]
provides(Binaries, Dict(URI("https://github.com/barche/QML.jl/releases/download/v0.1.0/QML.zip") => deps), os = :Windows)

@BinDeps.install

@windows_only pop!(BinDeps.defaults)
