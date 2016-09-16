using BinDeps
using CxxWrap
using Compat
libdir_opt = ""
@static if is_windows()
  libdir_opt = Sys.WORD_SIZE==32 ? "32" : ""
end

@static if is_windows()
  # prefer building if requested
  if haskey(ENV, "BUILD_ON_WINDOWS") && ENV["BUILD_ON_WINDOWS"] == "1"
    saved_defaults = deepcopy(BinDeps.defaults)
    empty!(BinDeps.defaults)
    append!(BinDeps.defaults, [BuildProcess])
  end
end

@BinDeps.setup

cxx_wrap_dir = Pkg.dir("CxxWrap","deps","usr","lib","cmake")

qmlwrap = library_dependency("qmlwrap", aliases=["libqmlwrap"])
prefix=joinpath(BinDeps.depsdir(qmlwrap),"usr")
qmlwrap_srcdir = joinpath(BinDeps.depsdir(qmlwrap),"src","qmlwrap")
qmlwrap_builddir = joinpath(BinDeps.depsdir(qmlwrap),"builds","qmlwrap")
lib_prefix = @static is_windows() ? "" : "lib"
lib_suffix = @static is_windows() ? "dll" : (@static is_apple() ? "dylib" : "so")

makeopts = ["--", "-j", "$(Sys.CPU_CORES+2)"]

# Set generator if on windows
genopt = "Unix Makefiles"
@static if is_windows()
  makeopts = "--"
  if Sys.WORD_SIZE == 64
    genopt = "Visual Studio 14 2015 Win64"
  else
    genopt = "Visual Studio 14 2015"
  end
end

qml_steps = @build_steps begin
	`cmake -G "$genopt" -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_BUILD_TYPE="Release" -DCxxWrap_DIR="$cxx_wrap_dir" -DLIBDIR_SUFFIX=$libdir_opt $qmlwrap_srcdir`
	`cmake --build . --config Release --target install $makeopts`
end

# If built, always run cmake, in case the code changed
if isdir(qmlwrap_builddir)
  BinDeps.run(@build_steps begin
    ChangeDirectory(qmlwrap_builddir)
    qml_steps
  end)
end

provides(BuildProcess,
  (@build_steps begin
    CreateDirectory(qmlwrap_builddir)
    @build_steps begin
      ChangeDirectory(qmlwrap_builddir)
      FileRule(joinpath(prefix,"lib$libdir_opt", "$(lib_prefix)qmlwrap.$lib_suffix"),qml_steps)
    end
  end),qmlwrap)

deps = [qmlwrap]
provides(Binaries, Dict(URI("https://github.com/barche/QML.jl/releases/download/v0.1.0/QML-julia-$(VERSION.major).$(VERSION.minor)-win$(Sys.WORD_SIZE).zip") => deps), os = :Windows)

@BinDeps.install Dict([(:qmlwrap, :_l_qml_wrap)])

@static if is_windows()
  if haskey(ENV, "BUILD_ON_WINDOWS") && ENV["BUILD_ON_WINDOWS"] == "1"
    empty!(BinDeps.defaults)
    append!(BinDeps.defaults, saved_defaults)
  end
end
