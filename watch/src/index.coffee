> x/On.js

< (input, next)=>
  + typeing

  pre = input.value

  change = =>
    if typeing
      return

    val = input.value

    if val != pre
      pre = val
      next(val)

    return

  On(
    input
    {
      input:change
      compositionstart: =>
        typeing = 1
        return
      compositionend: =>
        typeing = 0
        change()
        return
    }
  )
