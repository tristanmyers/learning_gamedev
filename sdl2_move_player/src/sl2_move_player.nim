import sdl2
import std/options

var
  purple: Color = (r: uint8 0x66, g: uint8 0x04, b: uint8 0x9b,
      a: uint8 SDL_ALPHA_OPAQUE)
  green: Color = (r: uint8 0x51, g: uint8 0xad, b: uint8 0x6a,
      a: uint8 SDL_ALPHA_OPAQUE)
  yellow: Color = (r: uint8 0xde, g: uint8 0xfc, b: uint8 0x8d,
      a: uint8 SDL_ALPHA_OPAQUE)

proc initGame(window: var WindowPtr, screenSurface: var SurfacePtr): void =
  if sdl2.init(INIT_VIDEO) == SdlError:
    stderr.writeLine("Error initializing sld2", getError())

  # This is also creating a surface the same size as the window.
  window = sdl2.createWindow(title = "Handling some events",
      x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED, w = 800, h = 600,
      flags = SDL_WINDOW_SHOWN)
  if isNil(window):
    stderr.writeLine("Error creating window ", getError())

  screenSurface = window.getSurface
  fillRect(screenSurface, nil, mapRGB(screenSurface.format, green.r, green.g, green.b))
  discard window.updateSurface

# I think having optional parameters is more appoproiate here than procedure overrides since there is not much logic difference
proc quitGame(window: Option[WindowPtr], renderer: Option[RendererPtr],
    surface: Option[SurfacePtr]): void =
  if surface.isSome(): sdl2.freeSurface(get(surface))
  if renderer.isSome(): sdl2.destroy(get(renderer))
  if window.isSome(): sdl2.destroy(get(window))

  sdl2.quit()

# TODO: Is there a better way to set these parameters?
proc handleEvents(event: var Event, playerSurface: var SurfacePtr, window: var WindowPtr, renderer: var RendererPtr, playing: var bool): void =
  while event.pollEvent:
    case event.kind
      of KeyDown:
        let scancode = event.key.keysym.scancode

        if scancode == SDL_SCANCODE_Q:
          quitGame(surface = option(playerSurface), window = option(window),
                          renderer = option(renderer))
          playing = false

        if scancode == SDL_SCANCODE_D:
          # Move player right
          discard

      of QuitEvent:
        quitGame(surface = option(playerSurface), window = option(window),
                        renderer = option(renderer))
        playing = false

      else: discard



when isMainModule:
  var
    playing = true
    window: WindowPtr = nil
    # A renderer is not needed to use a surface but is good when hardware acceleration is needed
    renderer: RendererPtr = nil
    screenSurface: SurfacePtr = nil
    playerSurface: SurfacePtr = nil
    event: Event

  initGame(window, screenSurface)
  
  while playing:
    # Without a delay the cpu would be at 100% while the game is running.
    sdl2.delay(5)
    handleEvents(event, playerSurface, window, renderer, playing)

    if playing:
      if isNil(playerSurface):
        stdout.writeLine("loaded image")
        # NOTE: Executable needs to be ran from the directory that the image is in.
        playerSurface = sdl2.loadBMP("./player1.bmp")
        if isNil(playerSurface):
          stderr.writeLine("Error loading player image ", getError())

      # Render image on to back buffer
      sdl2.blitSurface(playerSurface, nil, screenSurface, nil)
      # Update front buffer with back buffer
      if window.updateSurface == SdlError:
        stderr.writeLine("Error updating surface ", getError())


