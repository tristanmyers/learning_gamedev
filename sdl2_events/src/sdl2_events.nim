import sdl2
import os

proc quitGame(renderer: RendererPtr, window: WindowPtr): void =
  renderer.destroy()
  window.destroy()
  sdl2.quit()


when isMainModule:
  var
    playing = true

  sdl2.init(INIT_VIDEO)
  let window = sdl2.createWindow(title = "Handling some events",
      x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED, w = 800, h = 600,
      flags = SDL_WINDOW_SHOWN)
  if isNil(window):
    stderr.writeLine("Error creating window ", getError())

  # A renderer is not needed to use a surface but is good when hardware acceleration is needed
  let renderer = sdl2.createRenderer(window, -1, Renderer_Accelerated)
  if isNil(renderer):
    stderr.writeLine("Error creating renderer ", getError())

  while playing:
    var
      rect: Rect

    let surface = createRGBSurface(flags = 0, width = 120, height = 120,
        depth = 8, 0, 0, 0, 0)
    if isNil(surface):
      stderr.writeLine("Error creating surface ", getError())

    rect.x = 0
    rect.y = 0
    rect.w = 100
    rect.h = 100

    let
      srcRect = addr(rect)
      dstRect = addr(rect)


    # blitSurface(src = surface, srcrect = srcRect, dst = surface, dstRect = dstRect)
    # discard updateSurface(window)

    let texture = createTextureFromSurface(renderer, surface)
    if isNil(texture):
      stderr.writeLine("Error creating texture ", getError())

    # copy(renderer, texture, nil, nil)
    present(renderer)

    sleep(2000)
    playing = false

  quitGame(renderer, window)
