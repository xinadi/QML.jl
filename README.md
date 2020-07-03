# QML

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://barche.github.io/QML.jl/dev)
[![Build Status](https://travis-ci.org/barche/QML.jl.svg?branch=master)](https://travis-ci.org/barche/QML.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/7edud4w38g8m17yw?svg=true)](https://ci.appveyor.com/project/barche/qml-jl)

This package provides an interface to [Qt5 QML](http://qt.io/). It uses the [`CxxWrap`](https://github.com/barche/CxxWrap.jl) package to expose C++ classes. Current functionality allows interaction between QML and Julia using basic numerical and string types, as well as display of PNG images and a very experimental OpenGL rendering element (see `example/gltriangle.jl`).

![QML plots example](example/plot.png?raw=true "Plots example")

![OpenGL example](example/gltriangle.gif?raw=true "OpenGL example, using GLAbstraction.jl")

## Installation
The current master version is experimental for Julia 1.0, and no binaries are available yet. Please build the binary part from [JlQml](https://github.com/barche/jlqml) first, and then set the `JLQML_DIR` environment variable to the path to the jlqml build directory. After that, run, in pkg mode:
```text
add QML#master
```

On Linux and macOS, compilation should be automatic, with dependencies installed by the packagemanager or Homebrew.jl. On Windows, binaries are downloaded. To use a non-standard Qt, set the environment variable `QT_ROOT` to the base Qt directory (the one containing `lib` and `bin` on macOS and linux, or the directory containing `msvc2015_64` or `msvc2015` on Windows).

You can check that the correct Qt version is used using the `qt_prefix_path()` function.

### Raspberry Pi
Because of issues with LLVM library compatibility between the graphics driver on the Raspberry Pi and Julia, QML.jl will only work if you build Julia from source, using the system LLVM version 3.9. Install the `llvm-3.9-dev` package, and then build Julia with the following Make.user:

```
override LLVM_CONFIG=llvm-config-3.9
override USE_SYSTEM_LLVM=1
```

## Usage

### Running examples
To run the included examples, execute:

```julia
include(joinpath(Pkg.dir("QML"), "example", "runexamples.jl"))
```

The examples require some additional packages to be described by the manifest and project files in the examples directory, so from the examples directory you should
start Julia with `julia --project` and then run `instantiate` from the pkg shell.

For further examples, see the [`documentation`](https://barche.github.io/QML.jl/dev).

## Breaking changes
* Signals in `JuliaSignals` must have arguments of type `var`
* Role indices are 1-based now on the Julia side
* The interface of some functions has changed because of the way CxxWrap handles references and pointers more strictly now
* No more automatic conversion from `String` to `QUrl`, use the `QUrl("mystring")` constructor
* Setting a `QQmlPropertyMap` as context object is not supported as of Qt 5.12
