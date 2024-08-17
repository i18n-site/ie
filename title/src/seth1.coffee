> ./mountTitle.js
< (m)=>
  return mountTitle m.getElementsByTagName(
    'h1'
  )[0]?.innerText
