> @2-/focus
  @2-/new:New
  @2-/ing:Ing

E = 'E' # class error
CLS_E = '.'+E
CHANGE = 'change'
EV = [CHANGE,'keydown']


removeE = (p)=>
  p.classList.remove E
  for i from p.querySelectorAll CLS_E
    i.remove()
  return

removeB = ->
  p = @parentNode
  removeE p
  for ev from EV
    @removeEventListener ev, removeB
  return

EV_TAG = ['INPUT','TEXTAREA']

< clear = (form)=>
  for i from form.querySelectorAll 'u'+CLS_E
    removeE i
  return

< (form, promise)=>
  clear form
  try
    return await Ing(form,promise)
  catch err
    if err != undefined
      if Array.isArray err
        + first
        for [k,v] from err
          i = form.querySelector '#'+k
          if i
            {b} = New
            b.className = E
            b.innerHTML = v
            p = i.parentNode
            p.classList.add E
            p.appendChild b
            if EV_TAG.includes i.tagName
              for ev from EV
                i.addEventListener ev, removeB
              if not first
                first = 1
                i.focus()
                i.select()
      else
        throw err
    else
      focus(form)
  return null
