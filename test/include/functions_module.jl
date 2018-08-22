module TestModuleFunction

export set_state1, get_state

state = 0

function set_state1()
  global state
  state = 1
  return
end

function set_state2()
  global state
  if(state == 1)
    state = 2
  end
  return
end

function get_state()
  return state
end

end
