using BinDeps

@BinDeps.setup

cpp_wrapper_dir = joinpath(Pkg.dir("CppWrapper"),"deps","usr","lib","cmake")

qml_wrapper = library_dependency("qml_wrapper", aliases=["libqml_wrapper"])
prefix=joinpath(BinDeps.depsdir(qml_wrapper),"usr")
qml_wrapper_srcdir = joinpath(BinDeps.depsdir(qml_wrapper),"src","qml_wrapper")
qml_wrapper_builddir = joinpath(BinDeps.depsdir(qml_wrapper),"builds","qml_wrapper")
lib_suffix = @windows? "dll" : (@osx? "dylib" : "so")
provides(BuildProcess,
	(@build_steps begin
		CreateDirectory(qml_wrapper_builddir)
		@build_steps begin
			ChangeDirectory(qml_wrapper_builddir)
			FileRule(joinpath(prefix,"lib", "libqml_wrapper.$lib_suffix"),@build_steps begin
				`cmake -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_BUILD_TYPE="Release" -DCppWrapper_DIR="$cpp_wrapper_dir" $qml_wrapper_srcdir`
				`make`
				`make install`
			end)
		end
	end),qml_wrapper)

@BinDeps.install
