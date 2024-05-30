> ./index.js:set

< (title)=>
  t = document.title
  if title
    set title
    return =>
      set t
      return
  return
