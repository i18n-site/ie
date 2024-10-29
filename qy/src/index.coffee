> @2-/pre_lines:lines
  @3-/seg
  idb > openDB

`const _docWord='docWord',_doc='doc',_word='word', _w="w",_rindex='rindex',_prefix='prefix',_wid='wordId',_docId='docId',ID='id',_URL='url',readonly='readonly'`

ngram = (word) =>
  len = word.length - 1
  r = []
  i = j = 0
  while j < len
    r.push word.slice(i, ++j)
  r

pusher = =>
  ing = new Map()
  (table, id, val)=>
    id_set = ing.get(id)
    if id_set
      id_set.add val
      return

    id_set = new Set([val])
    ing.set id, id_set
    pre = await table.get(id)
    li = pre?.li or []

    loop
      to_add = [...id_set]
      li.push(...to_add)
      await table.put({id,li})
      for i from to_add
        id_set.delete i
      if not id_set.size
        ing.delete id
        break
    return

rindexPush = pusher()
prefixPush = pusher()

txStore = (tx, name)=>
  tx.objectStore(name)

export default (
  lang
  url_ver_li # [[url,ver],[url,ver]]
  get # get([lang,url,ver]) -> txt
  incr
) =>
  word_id = new Map()

  db = await openDB "Q#{lang}", 3,
    upgrade: (db) =>
      db.createObjectStore(
        _docWord
        keyPath: ID
      )
      for [table, index] from [
        [_doc, _URL]
        [_word, _w]
      ]
        db.createObjectStore(
          table
          keyPath: ID
          autoIncrement: true
        ).createIndex(
          index
          index
          unique: true
        )

      for i from [
        [_rindex, keyPath: ID, unique: true]
        [_prefix, keyPath: ID, unique: true]
      ]
        db.createObjectStore ...i

      return

  rw = =>
    db.transaction [_docWord,_doc,_word,_rindex,_prefix], 'readwrite'

  wordId = (tx, w) =>
    id = exist_id = word_id.get(w)
    if not exist_id
      word_id.set(w, 0)
      word = txStore(tx,_word)
      if exist_id == 0
        loop
          id = await word.index(_w).getKey(w)
          if id
            break
      else
        id = (
          await word.index(_w).getKey(w)
        ) or await word.add({ w })

      word_id.set(w, id)
      store = txStore(tx,_prefix)
      ngram(w).forEach(
        (prefix) =>
          prefixPush(store,prefix,id)
          return
      )
    id

  rmWord = (tx, id) =>
    store = txStore(tx,_word)
    r = await store.get(id)
    if r
      { w } = r
      word_id.delete(w)
      prefix = txStore(tx,_prefix)
      ngram(w).forEach(
        (prefix) =>
          o = await prefix.get(prefix)
          if o
            { li } = o
            p = li.indexOf(id)
            if ~p
              li.splice(p, 1)
              if li.length
                prefix.put(o)
              else
                prefix.delete(prefix)
          return
      )
      store.delete id
    return

  addDoc = (url,ver)=>
    txt = lines((await get(lang, url, ver)).toLocaleLowerCase())
    tx = rw()
    doc_id = await txStore(tx,_doc).put({ url, ver })
    word = txStore(tx,_word)
    rindex = txStore(tx,_rindex)

    word_pos = new Map
    for line,pos in txt
      for w from new Set seg(line)
        exist = word_pos.get(w)
        if exist
          exist.push pos
        else
          word_pos.set(w, [pos])

    id_li = []

    index = ([w,pos])=>
      id = await wordId(tx, w)
      id_li.push id
      rindexPush(rindex, id, [doc_id,pos])

    await Promise.all(
      index(i) for i from word_pos.entries()
    )

    await txStore(tx,_docWord).add(
      {
        id: doc_id
        li: id_li
      }
    )
    incr()
    return


  rmDoc = (tx,id)=>
    rindex = txStore(tx,_rindex)
    word = txStore(tx,_word)

    ing = []
    doc_word = await txStore(tx,_docWord).get(id)
    if doc_word
      ing.push ...doc_word.li.map (wordId) =>
        rindex_item = await rindex.get(wordId)
        if rindex_item
          {li} = rindex_item

          for i,p in li
            if id == i[0]
              li.splice(p, 1)
              if li.length
                await rindex.put(rindex_item)
              else
                await rindex.delete(wordId)
                await rmWord(tx, wordId)
              break
        return

    ing.push(
      txStore(tx,_docWord).delete(id)
      txStore(tx,_doc).delete(id)
    )
    await Promise.all ing
    return


  search = (keyword_li, limit)->
    if not keyword_li.length
      return []
    tx = db.transaction([_rindex,_prefix,_word,_doc], readonly)
    rindex = txStore(tx, _rindex)
    word = txStore(tx, _word)
    prefix = txStore(tx, _prefix)
    word_index = word.index(_w)

    wordIdNoNew = (word)=>
      word_id.get(word) or await word_index.getKey(word)

    total = keyword_li.length
    last = keyword_li.pop()

    id_li = []
    exist = new Set

    for i in keyword_li
      id = await wordIdNoNew(i)
      if id and not exist.has id
        exist.add id
        id_li.push id

    doc_line_count = new Map
    await Promise.all id_li.map (id)=>
      o = await rindex.get(id)
      if o
        for [doc_id, line_li] from o.li
          line_count = doc_line_count.get(doc_id)
          if not line_count
            line_count = new Map
            doc_line_count.set(doc_id, line_count)
          for line from line_li
            line_count.set line, 1+(line_count.get(line) or 0)
      return

    searched_id_li = []
    searched = new Map
    returned = new Map
    文档 = txStore(tx, _doc)

    rt = (doc_id_li)=>
      Promise.all doc_id_li.map (doc_id)=>
        {url, ver} = await 文档.get doc_id
        [
          url
          searched.get doc_id
          await get(lang, url, ver)
        ]

    reopen = =>
      tx = db.transaction([_rindex,_doc], readonly)
      文档 = txStore(tx, _doc)
      rindex = txStore(tx, _rindex)

      searched_id_li = []
      searched = new Map
      return

    searchPush = (doc_id, line, count)=>
      pre = searched.get doc_id
      if not pre
        searched_id_li.push doc_id
        pre = []
        searched.set doc_id, pre

      pre.push [line,count]

      if searched_id_li.length == limit
        return rt searched_id_li
      return

    last_id_li = []
    last_id = await wordIdNoNew(last)
    if last_id
      last_id_li.push last_id

    prefix_li = await prefix.get(last)
    if prefix_li
      last_id_li.push ...prefix_li.li

    exist_last = new Map

    for last_id in last_id_li
      o = await rindex.get(last_id)
      if o
        for [doc_id, line_li] from o.li
          line_count = doc_line_count.get(doc_id) or new Map
          exist = returned.get doc_id
          if not exist
            exist = new Set
            returned.set doc_id, exist

          el = exist_last.get doc_id
          if not el
            el = new Set
            exist_last.set doc_id, el

          for line from line_li
            if exist.has line
              continue

            n = (line_count.get(line) or 0)+1
            if n >= total
              line_count.delete line
              el.delete line
              exist.add line

              r = searchPush doc_id, line, total
              if r
                yield r
                reopen()
            else
              el.add line


    for [doc_id, line_set] in exist_last.entries()
      t = doc_line_count.get doc_id
      if t
        for line from line_set
          t.set(line, 1+(t.get(line) or 0))

    li = []
    for [doc_id, line_count] from doc_line_count.entries()
      for [line,count] from line_count.entries()
        li.push [count, doc_id, line]
    li.sort (a,b)=>b[0]-a[0]


    for [count, doc_id, line] from li
      r = searchPush doc_id, line, count
      if r
        yield r
        reopen()

    if searched_id_li.length
      yield rt searched_id_li

    return

  await do =>
    tx = rw()
    doc = new Map(
      (
        await txStore(tx,_doc).getAll()
      )
      .map((d) => [d.url, [d.id,d.ver]])
    )

    ing = []
    for [url, ver] in url_ver_li
      exist = doc.get(url)
      if exist
        doc.delete(url)
        if ver == exist[1]
          incr()
          continue
        await rmDoc(tx,exist[0])
      ing.push addDoc(url,ver)

    for [id] from doc.values()
      await rmDoc(tx,id)

    await Promise.all(ing)
    return

  close = => db.close()

  return [
    search
    close
  ]

