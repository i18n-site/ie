< (p)=>
  while p
    if p.tagName == 'A'
      return p
    p = p.parentNode
  return
