PRE = document.createElement('pre')

export preLines = (txt)=>
  PRE.innerHTML = txt
  txt = PRE.innerText.replace(/(?<!`)`(?!`)/g, '')
  r = []
  for i from txt.replaceAll('\r\n','\n').replaceAll('\r','\n').split('\n')
    i = i.trim()
    if i
      r.push i
  [PRE,r]

export default (txt)=>
  preLines(txt)[1]
