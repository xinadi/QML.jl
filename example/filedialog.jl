using QML

function singlefile(uri)
  if isempty(uri)
    println("multiple files were selected")
    return
  end
  println("selected single file $uri")
end

function multifile(uri_list)
  println("selected paths:")
  for f in uri_list
    println("$f", isfile(f) ? " (file)" : "")
  end
end

@qmlfunction singlefile multifile

load(joinpath(dirname(Base.source_path()), "qml", "filedialog.qml"))
exec()