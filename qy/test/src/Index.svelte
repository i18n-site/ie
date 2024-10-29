<template lang="pug">
+if li
  +each li as [url, title, show, hide]
    a(href:url) {@html title}

    +if show.length
      +each show as [[url, section], ...lines]
        +if section
          a(href:url)
            h2 {@html section}
        main
          +each lines as line
            a(href:url) {@html line}

      +if hide?.length
        a.M 等 {hide.length} 条 …
  +else
    p todo
</template>

<script lang="coffee">
>  @2-/qy

+ li

onMount =>
  url_ver = [
    [
      "i18n.site"
      "0.1.138"
    ]
    [
      "i18/feature"
      "0.1.83"
    ]
  ]
  total = url_ver.length
  [search, close] = await qy(
    "zh"
    url_ver
    (lang,url,ver)=>
      r = await fetch "https://unpkg.com/i18md@#{ver}/#{lang}/#{url}.md"
      r.text()
    =>
      console.log 'wait indexed', --total
      return
    10
  )

  query = "翻译的网站内容"

  iter = search(query)
  li = (await iter.next()).value

  console.log li
  =>
    close()
    return
</script>

<style lang="stylus">
a.M
  font-size 14px

main
  a
    color #000
    display block
    font-size 16px

h2
  font-size 16px
  margin 0

:global(b.h)
  background #ff0
  color #e30
</style>
