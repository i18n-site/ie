< (p, e)=>
  if p.host == location.host
    {hash} = p
    url = p.pathname.slice(1) + p.search
    if hash
      url += hash
    e.preventDefault()
    return url
  return
