> @2-/new:New
  @3-/vb/vbE.js
  @3-/b64/b64e.js

< =>
  {
    screen: {
      width
      height
    }
    devicePixelRatio
  } = window
  {
    hardwareConcurrency:hw
    userAgentData:ua
  } = navigator

  base = [
    width
    height
    Math.round(10*devicePixelRatio) or 0
    new Date().getTimezoneOffset() + 720
    hw
  ]
  r = [
    navigator.languages[0]
  ]

  try
    {platformVersion, architecture} = await ua.getHighEntropyValues ['platformVersion','architecture','uaFullVersion']
    base.push ...platformVersion.split('.').slice(0,2).map((i)=>+i or 0)
    r.push 0+architecture

  r.unshift b64e vbE base

  try
    gl = New.canvas.getContext('webgl')
    d = gl?.getExtension('WEBGL_debug_renderer_info')
    if d
      r.push 1+gl.getParameter(d.UNMASKED_RENDERER_WEBGL)
  r.join('<')
