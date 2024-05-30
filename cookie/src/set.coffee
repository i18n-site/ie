> ./tld.js:@ > _cookieSet

tld()

export default (k,v,t)=>
  if not t
    t = if v then 1e11 else 0

  _cookieSet(
    k+'='+v
    t
  )
  return
