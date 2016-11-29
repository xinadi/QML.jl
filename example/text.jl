using QML

qmlfile = joinpath(dirname(Base.source_path()), "qml", "text.qml")

fromcontext = "From context property"
fromfunction() = "From function call"
@qmlfunction fromfunction

# All qmlapp arguments after the QML file path are interpreted as context properties with the same name
@qmlapp qmlfile fromcontext
exec()

"""
Example for setting text from Julia
"""
