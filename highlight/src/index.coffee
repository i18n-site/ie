> @2-/pre_lines > preLines
  @3-/htm_escape:htmEscape
  @3-/re_escape:reEscape

cut = (txt) =>
  len = 200
  if txt.length > len then txt.slice(0, len) + ' …' else txt

export default (word_li)=>
  word_li = word_li.toSorted((a, b) => b.length - a.length)
  pattern = word_li.map((word) -> reEscape(word)).join('|')
  regex = new RegExp(pattern, 'gi')

  highlight = (txt) =>
    ranges = []
    txt.replace(
      regex
      (match, offset) =>
        ranges.push([offset, offset + match.length])
        return
    )
    marged = []
    len = -1
    for range in ranges
      if len<0 or marged[len][1] < range[0]
        ++len
        marged.push(range)
      else
        marged[len][1] = range[1]

    if not marged.length
      return htmEscape txt

    marged00 = marged[0][0]
    pre = Math.max(
      0
      marged00 - 70
    )

    if pre > 0
      m = txt.slice(pre, marged00).match(/(?!`)\p{P}/u)
      if m
        pre += (1+m.index)
      r = '… '
    else
      r = ''

    for [start, end] in marged
      r += htmEscape(cut(txt.slice(pre, start))) + '<b class="h">' + htmEscape(txt.slice(start, end)) + '</b>'
      pre = end

    r += htmEscape cut(txt.slice(end))
    r

  (line_count,txt,genurl) =>
    [pre, lines] = preLines(txt)
    title = pre.getElementsByTagName('h1')[0]?.innerText

    title_li = []
    + in_code
    for i,pos in lines
      if i.startsWith('```')
        in_code = !in_code
      if in_code
        continue
      if i.startsWith('#')
        p = i.indexOf(' ')
        if p>0
          t = i.slice(p+1).trim()
          if t
            title_li.push [
              t
              pos
              p
            ]

    if not title
      title = title_li[0]?[0]

    t = show = []
    hidden = []
    + pre_pos
    if line_count.length
      pre_count = line_count[0][1]
      for [pos,count] from line_count
        if pre_count != count
          t = hidden
        pre_pos = lipush(
          highlight
          lines
          pos
          title_li
          pre_pos
          t
          genurl
        )
    if title
      title = highlight title
    r = [
      title
      show
    ]
    if hidden.length
      r.push hidden
    r


titleHtm = (highlight, title_li, pos, genurl) =>
  if pos <= 0
    pos = 0
  [
    if pos > 0 then genurl(pos) else genurl()
    highlight title_li[pos]?[0] or '-'
  ]

lipush = (highlight, lines, pos, title_li, pre_pos, li, genurl)=>

  last_pos = -1

  for [_, title_pos, level], _pos in title_li
    if title_pos > pos
      break
    last_pos = _pos

  same_as_pre = last_pos == pre_pos
  title_pos = title_li[last_pos]?[1]
  same_as_title = pos == title_pos

  if same_as_pre and same_as_title
    return last_pos

  htm = highlight(lines[pos])
  if same_as_pre
    if not li.length
      li.push [[]]
    li.at(-1).push htm
  else if last_pos > 0 or not li.length
    if last_pos > 0
      t = titleHtm(highlight, title_li, last_pos, genurl)
    else
      t = [genurl()]
    li.push(
      `same_as_title ? [ t ] : [ t , htm ]`
    )

  return last_pos




