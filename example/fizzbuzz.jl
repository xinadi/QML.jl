using QML
"""
Translation of the FizzBuzz example from http://seanchas116.github.io/ruby-qml/
"""

type FizzBuzz
  result::AbstractString
  lastfizzbuzz::Int32
end

function do_fizzbuzz(input::AbstractString)
  global ctx
  if isempty(input)
    return
  end
  i = Int32(0)
  try
    i = parse(Int32, input)
  catch
    @qmlset ctx.fizzbuzz.result = "parse error"
  end
  if i % 15 == 0
    @qmlset ctx.fizzbuzz.lastfizzbuzz = i
    @qmlset ctx.fizzbuzz.result = "FizzBuzz"
  elseif i % 3 == 0
    @qmlset ctx.fizzbuzz.result = "Fizz"
  elseif i % 5 == 0
    @qmlset ctx.fizzbuzz.result = "Buzz"
  else
    @qmlset ctx.fizzbuzz.result = input
  end
  nothing
end

# Create the Qt app
app = QML.application()
eng = QQmlApplicationEngine()

# Set up the context
ctx = root_context(eng)
fb = FizzBuzz("", 0)
@qmlset ctx.fizzbuzz = fb

# Load the QML
load(eng, joinpath(dirname(Base.source_path()), "qml", "fizzbuzz.qml"))

QML.exec()
