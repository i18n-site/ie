+ TLD

export _cookieSet = (kv,t)=>
  n = new Date()
  s = +n
  n.setTime(s+t)
  document.cookie = kv + ';expires='+ n.toUTCString() + ';domain=' + TLD
  return

export default =>
  if not TLD
    i = 0
    p = document.domain.split('.')
    s = +new Date
    k = '_'+s
    v = k+'='+s
    while i < p.length - 1 and document.cookie.indexOf(v) == -1
      TLD = p.slice(-1 - ++i).join('.')
      _cookieSet v,1e3
  return TLD
