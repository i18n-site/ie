> ./setUrl.js
  ./index.js > refresh preUrl
  ./removeSlash.js
  @3-/split

J = '#'

< (url)=>
  url = removeSlash url
  purl = preUrl()
  if url == purl
    return
  setUrl(url)
  if split(url,J)[0] != split(purl,J)[0]
    refresh(url)
  return

