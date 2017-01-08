# This example show how to update the GUI dusing a long-running simulation

using Base.Test
using QML

qmlfile = joinpath(dirname(Base.source_path()), "qml", "progressbar.qml")

type SimulationState
  progress::Float64
end

const simulation_state = SimulationState(0.0)

# Our simulation is just a busy wait, producing progress between 0.0 and 1.0
function simulate()
  counter = 0.0
  maxcount = 1000000000.0
  while counter < maxcount
    for i in 1:Int(maxcount/10)
      counter += 1.0
    end
    produce(counter/maxcount)
  end
  produce(1.0)
end

simulation_task = Task(simulate)

# Run a step in the simulation, restart if already finished
function step()
  global simulation_state
  global simulation_task

  if simulation_state.progress >= 1.0
    println("Simulation was finished, restarting")
    simulation_task = Task(simulate)
  end

  @show progress = consume(simulation_task)
  @qmlset qmlcontext().simulation_state.progress = progress

  return
end

# Register the stepping function function
@qmlfunction step

# The timer will run simulation steps as fast as it can while active, yielding to the GUI after each tick
timer = QTimer()

# All arguments after qmlfile are context properties:
@qmlapp qmlfile simulation_state timer
exec()
