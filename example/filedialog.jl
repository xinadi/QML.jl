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

qmlfile = joinpath(dirname(Base.source_path()), "qml", "filedialog.qml")
# Load the QML file, using position as a context property
@qmlapp qmlfile position
exec()