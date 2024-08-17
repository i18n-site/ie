ING = 'ing'

export default (
  el
  run
)=>
  c = el.classList
  c.add(ING)
  try
    return await run
  finally
    c.remove(ING)
  return

