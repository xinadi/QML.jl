using QML
using Observables
"""
Translation of the FizzBuzz example from http://seanchas116.github.io/ruby-qml/
"""

mutable struct FizzBuzz
  result::Observable{String}
  count::Observable{Int}
  success::Observable{Bool}
  FizzBuzz() = new(Observable(""), Observable(0), Observable(false))
end

function do_fizzbuzz(input::AbstractString, fb::FizzBuzz)
  if isempty(input)
    return
  end
  i = Int32(0)
  try
    i = parse(Int32, input)
  catch
    fb.result[] = "parse error"
  end
  if i % 15 == 0
    fb.result[] = "FizzBuzz"
    fb.success[] = true
    @emit fizzBuzzFound(i)
  elseif i % 3 == 0
    fb.result[] = "Fizz"
  elseif i % 5 == 0
    fb.result[] = "Buzz"
  else
    fb.result[] = input
  end
  if fb.count[] == 2 && !fb.success[]
    @emit fizzBuzzFail()
  end
  fb.count[] += 1
  nothing
end

@qmlfunction do_fizzbuzz

the_fizzbuzz = FizzBuzz()

qmlfile = joinpath(dirname(Base.source_path()), "qml", "fizzbuzz.qml")
load(qmlfile, fizzbuzz=the_fizzbuzz, fizzbuzzMessage=the_fizzbuzz.result)
exec()

print("""
State of fizzbuzz at exit:
  result: $(the_fizzbuzz.result[])
  count: $(the_fizzbuzz.count[])
""")
