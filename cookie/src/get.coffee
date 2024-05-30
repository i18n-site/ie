< (cookie)=>
  new Proxy(
    {}
    get: (_,name)=>
      k = name+'='
      p = cookie.indexOf(k)
      if ~p
        p += k.length
        end = cookie.indexOf(';',p)
        if end < 0
          end = cookie.length
        return cookie.slice(p,end)
      return
  )
