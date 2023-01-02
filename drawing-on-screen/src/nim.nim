import sdl2
import std/[os, random]

type
  Window = object
    title: cstring
    x, y: cint
    w, h: cint
    flags: uint32

proc createRect(renderer: RendererPtr, rect: var Rect) =
  setDrawColor(renderer = renderer, r = uint8(rand(0..255)), g = uint8(rand(
      0..255)), b = uint8(rand(0..255)), a = SDL_ALPHA_OPAQUE)
  fillRect(renderer, rect) # This is now on the backbuffer

when isMainModule:
  var
    windowOptions = Window(title: "Learn game", x: SDL_WINDOWPOS_CENTERED,
        y: SDL_WINDOWPOS_CENTERED, w: 1024, h: 768, flags: SDL_WINDOW_SHOWN)
    windowRect: Rect = (x: cint(0), y: cint(0), w: windowOptions.w,
        h: windowOptions.h)
    rect: Rect
    rectCount: int

  sdl2.init(INIT_VIDEO) # event handling is initialized with video

  let window = sdl2.createWindow(title = windowOptions.title,
      x = windowOptions.x, y = windowOptions.y, w = windowOptions.w,
      h = windowOptions.h, flags = windowOptions.flags)

  let renderer = sdl2.createRenderer(window = window, index = -1,
      flags = Renderer_Accelerated)

  # Draw a rectangle that covers whole window
  setDrawColor(renderer = renderer, r = 0, g = 0, b = 0)
  fillRect(renderer, windowRect)
  present(renderer)

  rect.x = 0
  rect.y = 0
  rect.w = 20
  rect.h = 20

  var
    rectsOnX = windowRect.w div rect.w
    rectsOnY = windowRect.h div rect.h

  rectCount = rectsOnX * rectsOnY

  randomize()
  var i = 0
  while i <= rectCount:
    # NOTE: There should be a HasIntersection proc in the sld2 lib but I guess this was never added.
    # Should handle when the y is intersecting but I'm not sure what to do when that happens
    if rect.x + rect.w > windowRect.w:
      rect.y += rect.h + 1
      rect.x = 0

    createRect(renderer, rect)

    # Move next to the previous square
    rect.x += rect.w + 1
    i += 1

  present(renderer) # Update the screen with whatever is on the backbuffer

  sleep(2000)

  renderer.destroy() # even though the renderer is destroyed what was on the screen stays.
  window.destroy()
  sdl2.quit()
