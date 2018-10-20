# This example show how to update the GUI during a long-running simulation
using Test
using QML
using Observables
using ResumableFunctions
using Statistics

const nsteps = 100
const stepsize = Observable(0)

# Simple counting "simulation" with its interface
mutable struct Simulation
  counter::Int
  maxcount::Int
  stepsize::Int

  function Simulation()
    result = new(0, nsteps, stepsize[])
    on(stepsize) do n
      result.stepsize = n
    end
    return result
  end
end

isfinished(s) = s.counter == s.maxcount

function dostep(s::Simulation)
  if isfinished(s)
    error("Simulation is finished, can't step anymore")
  end
  
  if s.stepsize != 0
    sleep(s.stepsize/1000)
  end
  s.counter += 1
end

getprogress(s) = s.counter / s.maxcount
restart(s) = (s.counter = 0)

const simulation_types = [
  ("Direct", :direct),
  ("Channel", :channel),
  ("ResumableFunctions", :resumable)
]

qmlfile = joinpath(dirname(Base.source_path()), "qml", "progressbar.qml")

# Global state, accessible from QML
const simulation = Observable{Any}(nothing) # The simulation
const progress = Observable(0.0) # Simulation progress
const selectedsimtype = Observable(0) # Index of the selected simulation type
const ticks = Observable(0) # Number of times the timer has ticked

on(selectedsimtype) do i
  setup(simulation, simulation_types[i][2])
end

# Direct update of the simulation
function step(sim::Simulation)
  dostep(sim)
  progress[] = getprogress(sim)
end

# Track the simulation in a channel
function simulate_chan(c::Channel)
  sim = Simulation()
  while !isfinished(sim)
    dostep(sim)
    put!(c, getprogress(sim))
  end
end
function step(c::Channel)
  progress[] = take!(c)
end

# Track the simulation in a ResumableFunction
@resumable function simulate_resumable()
  sim = Simulation()
  while !isfinished(sim)
    dostep(sim)
    @yield getprogress(sim)
  end
end
function step(it::ResumableFunctions.FiniteStateMachineIterator)
  progress[] = it()
end

const timings = zeros(UInt64, nsteps)

function setup(observablesim, simtype)
  if simtype == :direct
    observablesim[] = Simulation()
  elseif simtype == :channel
    observablesim[] = Channel(simulate_chan)
  elseif simtype == :resumable
    observablesim[] = simulate_resumable()
  else
    error("Unknown simulation type $simtype")
  end
  progress[] = 0.0
  println("set up simulation $(simulation[])")
end

# set up initial simulation
selectedsimtype[] = 1

# Control the simulation using a QTimer, to hook into the Qt event loop
const timer = QTimer()

# Stop the timer when the simulation is at the end.
on(progress) do p
  if p >= 1.0
    QML.stop(timer)
    meantime = mean(timings[2:end] .- timings[1:end-1]) / 1e6
    println("Finished simulation after $(ticks[]) ticks with average time of $meantime ms between ticks")
    ticks[] = 0
    setup(simulation, simulation_types[selectedsimtype[]][2])
  end
end

on(ticks) do t
  ti = Int(t)
  if ti != 0 && ti <= length(timings)
    timings[ti] = time_ns()
    step(simulation[])
  end
end

# All arguments after qmlfile are context properties:
load(
  qmlfile,
  progress=progress,
  timer=timer,
  ticks=ticks,
  simulationTypes=ListModel(first.(simulation_types)),
  selectedSimType=selectedsimtype,
  stepsize=stepsize)

exec()

println("Simuation was at $(progress[]) in the end.")