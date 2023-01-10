import sdl2
import os

var
  # Renderer color
  purple: Color = (r: uint8 0x66, g: uint8 0x04, b: uint8 0x9b,
      a: uint8 SDL_ALPHA_OPAQUE)
  # Surface color
  green: Color = (r: uint8 0x51, g: uint8 0xad, b: uint8 0x6a,
      a: uint8 SDL_ALPHA_OPAQUE)
  # Rectangle color
  yellow: Color = (r: uint8 0xde, g: uint8 0xfc, b: uint8 0x8d,
      a: uint8 SDL_ALPHA_OPAQUE)

proc quitGame(window: WindowPtr): void =
  window.destroy()
  sdl2.quit()

proc quitGame(renderer: RendererPtr, window: WindowPtr): void =
  renderer.destroy()
  window.destroy()
  sdl2.quit()

proc quitGame(surface: SurfacePtr, window: WindowPtr): void =
  surface.freeSurface()
  window.destroy()
  sdl2.quit()

when isMainModule:
  var
    playing = true
    window: WindowPtr = nil
    screenSurface: SurfacePtr = nil
    playerSurface: SurfacePtr = nil

  if sdl2.init(INIT_VIDEO) == SdlError:
    stderr.writeLine("Error initializing sld2", getError())

  # This is also creating a surface the same size as the window.
  window = sdl2.createWindow(title = "Handling some events",
      x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED, w = 800, h = 600,
      flags = SDL_WINDOW_SHOWN)
  if isNil(window):
    stderr.writeLine("Error creating window ", getError())

  screenSurface = sdl2.getSurface(window)
  fillRect(screenSurface, nil, mapRGB(screenSurface.format, green.r, green.g, green.b))
  discard updateSurface(window)

  playerSurface = sdl2.loadBMP("./texture.bmp")
  if isNil(playerSurface):
    stderr.writeLine("Error loading player image ", getError())
  # Render image on to back buffer  
  sdl2.blitSurface(playerSurface, nil, screenSurface, nil)
  # Update front buffer with back buffer
  discard sdl2.updateSurface(window)

  # A renderer is not needed to use a surface but is good when hardware acceleration is needed
  # let renderer = sdl2.createRenderer(window, -1, Renderer_Accelerated)
  # if isNil(renderer):
  #   stderr.writeLine("Error creating renderer ", getError())

  sdl2.delay(2000)
  playing = false

  quitGame(playerSurface, window)
