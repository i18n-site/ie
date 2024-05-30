> x/On.js

< nowUrl = =>
  location.pathname.slice(1)

PRE = nowUrl()

HOOK = []

< (hook)=>
  HOOK.push hook
  return

< setPre = (url) =>
  PRE = url
  return

< preUrl = =>
  PRE

< refresh = (url)=>
  for f from HOOK
    f(url, PRE)
  setPre url
  return

On(
  window
  popstate: =>
    url = nowUrl()
    if url != PRE
      refresh(url)
    return
)
