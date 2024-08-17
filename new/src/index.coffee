< new Proxy(
  {}
  get:(_, tag)=>
    document.createElement tag
)
