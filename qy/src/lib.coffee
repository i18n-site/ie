> ./index.js:qy
  @2-/highlight
  @3-/seg > segqy

export default (
  lang
  url_ver_li # [[url,ver],[url,ver]]
  get # get([lang,url,ver]) -> txt
  incr
  limit
) =>
  [_search, close] = await qy(
    lang
    url_ver_li
    get
    incr
  )
  search = (v)->
    word_li = segqy v
    hl = highlight word_li
    for await li from _search(
      word_li, limit
    )
      yield li.map (
        [
          url, line_count, txt
        ]
      )=>
        url = '/' + url
        [url].concat hl(
          line_count
          txt
          (n)=>
            if n then url+'#H'+n else url
        )
    return
  [
    search
    close
  ]
