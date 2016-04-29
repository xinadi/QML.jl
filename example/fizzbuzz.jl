using QML
"""
Translation of the FizzBuzz example from http://seanchas116.github.io/ruby-qml/
"""

type FizzBuzz
  result::AbstractString
  count::Int
  success::Bool
end

function do_fizzbuzz(input::AbstractString)
  if isempty(input)
    return
  end
  i = Int32(0)
  try
    i = parse(Int32, input)
  catch
    @qmlset qmlcontext().fizzbuzz.result = "parse error"
  end
  if i % 15 == 0
    @qmlset qmlcontext().fizzbuzz.result = "FizzBuzz"
    fizzbuzz.success = true
    @emit fizzBuzzFound(i)
  elseif i % 3 == 0
    @qmlset qmlcontext().fizzbuzz.result = "Fizz"
  elseif i % 5 == 0
    @qmlset qmlcontext().fizzbuzz.result = "Buzz"
  else
    @qmlset qmlcontext().fizzbuzz.result = input
  end
  if fizzbuzz.count == 2 && !fizzbuzz.success
    @emit fizzBuzzFail()
  end
  fizzbuzz.count += 1
  nothing
end

qmlfile = joinpath(dirname(Base.source_path()), "qml", "fizzbuzz.qml")
fizzbuzz = FizzBuzz("", 0, false)

@qmlapp qmlfile fizzbuzz

@qmlfunction do_fizzbuzz

exec()
