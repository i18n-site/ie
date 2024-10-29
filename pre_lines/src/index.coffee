PRE = document.createElement('pre')

export preLines = (txt)=>
  PRE.innerHTML = txt.replace(
    # 避免加载资源, script
    /<\/?(?!h1\b)[a-z]+[^>]*>/gi
  ).replace(/(?<!`)`(?!`)/g, '')
  txt = PRE.innerText
  r = []
  for i from txt.replaceAll('\r\n','\n').replaceAll('\r','\n').split('\n')
    i = i.trim()
    if i
      r.push i
  [PRE,r]

export default (txt)=>
  preLines(txt)[1]
