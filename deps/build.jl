using BinDeps
using CxxWrap
using Compat

QT_ROOT = get(ENV, "QT_ROOT", "")

@static if is_windows()
  build_on_windows = false
  # prefer building if requested
  if QT_ROOT != ""
    build_on_windows = true
    saved_defaults = deepcopy(BinDeps.defaults)
    empty!(BinDeps.defaults)
    append!(BinDeps.defaults, [BuildProcess])
  end
end

@BinDeps.setup

cxx_wrap_dir = Pkg.dir("CxxWrap","deps","usr","lib","cmake")

qmlwrap = library_dependency("qmlwrap", aliases=["libqmlwrap"])

used_homebrew = false
if QT_ROOT == ""
  if is_apple()
    std_hb_root = "/usr/local/opt/qt5"
    if(!isdir(std_hb_root))
      if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
      end
      using Homebrew
      if !Homebrew.installed("qt5")
        Homebrew.add("qt5")
      end
      if !Homebrew.installed("cmake")
        Homebrew.add("cmake")
      end
      used_homebrew = true
      QT_ROOT = joinpath(Homebrew.prefix(), "opt", "qt5")
    else
      QT_ROOT = std_hb_root
    end
  end

  if is_linux()
    try
      run(pipeline(`cmake --version`, stdout=DevNull, stderr=DevNull))
      try
        run(pipeline(`qmake-qt5 --version`, stdout=DevNull, stderr=DevNull))
      catch
        run(pipeline(`qmake --version`, stdout=DevNull, stderr=DevNull))
      end
      run(pipeline(`qmlscene $(joinpath(dirname(@__FILE__), "imports.qml"))`, stdout=DevNull, stderr=DevNull))
    catch
      println("Installing Qt and cmake...")

      function printrun(cmd)
        println("Running install command, if this fails please run manually:\n$cmd")
        run(cmd)
      end

      if BinDeps.can_use(AptGet)
        printrun(`sudo apt-get install cmake cmake-data qtdeclarative5-dev qtdeclarative5-qtquick2-plugin qtdeclarative5-dialogs-plugin qtdeclarative5-controls-plugin qtdeclarative5-quicklayouts-plugin qtdeclarative5-window-plugin qmlscene qt5-default`)
      elseif BinDeps.can_use(Pacman)
        printrun(`sudo pacman -S --needed qt5-quickcontrols2`)
      elseif BinDeps.can_use(Yum)
        printrun(`sudo yum install cmake qt5-qtbase-devel qt5-qtquickcontrols qt5-qtquickcontrols2-devel`)
      end
    end
  end
end

cmake_prefix = QT_ROOT

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
    cmake_prefix = joinpath(QT_ROOT, "msvc2015_64")
  else
    genopt = "Visual Studio 14 2015"
    cmake_prefix = joinpath(QT_ROOT, "msvc2015")
  end
end

println("Using Qt from $cmake_prefix")

qml_steps = @build_steps begin
	`cmake -G "$genopt" -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_PREFIX_PATH="$cmake_prefix" -DCxxWrap_DIR="$cxx_wrap_dir" $qmlwrap_srcdir`
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
      FileRule(joinpath(prefix,"lib", "$(lib_prefix)qmlwrap.$lib_suffix"),qml_steps)
    end
  end),qmlwrap)

deps = [qmlwrap]
provides(Binaries, Dict(URI("https://github.com/barche/QML.jl/releases/download/v0.2.0/QML-julia-$(VERSION.major).$(VERSION.minor)-win$(Sys.WORD_SIZE).zip") => deps), os = :Windows)

@BinDeps.install Dict([(:qmlwrap, :_l_qml_wrap)])

@static if is_windows()
  if build_on_windows
    empty!(BinDeps.defaults)
    append!(BinDeps.defaults, saved_defaults)
  end
end

if used_homebrew
  # Not sure why this is needed on homebrew Qt, but here goes:
  envfile_path = joinpath(dirname(@__FILE__), "env.jl")
  plugins_path = joinpath(QT_ROOT, "plugins")
  qml_path = joinpath(QT_ROOT, "qml")
  open(envfile_path, "w") do envfile
    println(envfile, "ENV[\"QT_PLUGIN_PATH\"] = \"$plugins_path\"")
    println(envfile, "ENV[\"QML2_IMPORT_PATH\"] = \"$qml_path\"")
  end
end

import QML
if !QML.has_glvisualize
  println("GLVisualize support disabled. To use it, install the GLVisualize package.")
end
