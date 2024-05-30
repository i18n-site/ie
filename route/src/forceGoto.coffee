> ./setUrl.js
  ./index.js > refresh
  ./removeSlash.js

< (url)=>
  url = removeSlash url
  setUrl(url)
  refresh(url)
  return

