# QML
Small example for starting an interface to [Qt5 QML](http://qt.io/). It uses the [`CxxWrap`](https://github.com/barche/CxxWrap.jl) package to expose C++ classes. Current functionality allows loading a simple QML file, calling Julia functions and run a background task during event loop idle time. See test/gui.jl for details, docs not fully up-to-date.

## Installation
This was tested on Linux and OS X. You need `cmake` in your path for installation to work.

First install [`CxxWrap`](https://github.com/barche/CxxWrap.jl). Compilation of `QML.jl` requires Qt to be reachable by CMake. If it is in a non-standard location, set the environment variable `CMAKE_PREFIX_PATH` to the base Qt directory (the one containing `lib` and `bin`) before executing the following commands:

```julia
Pkg.clone("https://github.com/barche/QML.jl.git")
Pkg.build("QML")
Pkg.test("QML")
```

You can check that the correct Qt version is used using the `qt_prefix_path()` function.

## Usage

To run the QML file `main.qml` from the current directory, execute:
```julia
using QML

app = QML.application()
e = QQmlApplicationEngine("main.qml")
QML.exec()
finalize(app)
```

### Preventing crash-on-exit
To prevent a crash when exiting the program, the app object must be deleted manually, hence the call to `finalize(app)` in the above example.

In QML, include the `JuliaContext` component:
```qml
JuliaContext {
  id: julia
}
```

Then call a Julia function in QML using:
```qml
julia.call("my_function")
```

To call a function with arguments, put them in a list:
```qml
julia.call("my_function", [arg1, arg2])
```

See test for complete example.
