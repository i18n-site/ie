< (form)=>
  + first
  for i from form.getElementsByTagName 'input'
    if [
      'text'
      'password'
      'email'
    ].includes i.type
      if i.disabled
        continue
      v = i.value.trim()
      if not v
        i.value = v
        i.focus()
        return
      if not first
        first = i
  first?.focus()
  return


