import sdl2
import os
import std/options

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

# I think having optional parameters is more appoproiate here than procedure overrides since there is not much logic difference 
proc quitGame(window: Option[WindowPtr], renderer: Option[RendererPtr], surface: Option[SurfacePtr]): void = 
  if surface.isSome(): sdl2.freeSurface(get(surface))
  if renderer.isSome(): sdl2.destroy(get(renderer))
  if window.isSome(): sdl2.destroy(get(window))

  sdl2.quit()

when isMainModule:
  var
    playing = true
    window: WindowPtr = nil
    renderer: RendererPtr = nil
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

  playerSurface = sdl2.loadBMP("./player1.bmp")
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

  quitGame(surface = option(playerSurface), window = option(window), renderer = option(renderer))
