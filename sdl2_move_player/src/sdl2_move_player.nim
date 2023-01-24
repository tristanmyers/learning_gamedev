import sdl2
import std/options

type Position = tuple[x, y: int]

var
  purple: Color = (r: uint8 0x66, g: uint8 0x04, b: uint8 0x9b,
      a: uint8 SDL_ALPHA_OPAQUE)
  green: Color = (r: uint8 0x51, g: uint8 0xad, b: uint8 0x6a,
      a: uint8 SDL_ALPHA_OPAQUE)
  yellow: Color = (r: uint8 0xde, g: uint8 0xfc, b: uint8 0x8d,
      a: uint8 SDL_ALPHA_OPAQUE)

proc logError(msg: string): void = stderr.writeLine(msg, sdl2.getError())

proc setSurface(window: WindowPtr): void =
  let screenSurface = window.getSurface
  let surfaceFill = screenSurface.fillRect(nil, mapRGB(screenSurface.format,
      green.r, green.g, green.b))
  if surfaceFill == SdlError: logError("Error filling surface rect ")

proc initGame(window: var WindowPtr, renderer: var RendererPtr): void =
  if sdl2.init(INIT_VIDEO) == SdlError:
    logError("Error intializing sdl2 ")

  # This is also creating a surface the same size as the window.
  window = sdl2.createWindow(title = "Handling some events",
      x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED, w = 800, h = 600,
      flags = SDL_WINDOW_SHOWN)
  if isNil(window):
    logError("Error creating window ")

  window.setSurface

# NOTE: Maybe window and renderer doesn't need to be passed through as params, they maybe me something like getWindow
# I think having optional parameters is more appoproiate here than procedure overrides since there is not much logic difference
proc quitGame(window: Option[WindowPtr], renderer: Option[RendererPtr],
    surface: Option[SurfacePtr]): void =
  if surface.isSome(): sdl2.freeSurface(get(surface))
  if renderer.isSome(): sdl2.destroy(get(renderer))
  if window.isSome(): sdl2.destroy(get(window))

  sdl2.quit()

# TODO: Is there a better way to set these parameters?
proc handleEvents(event: var Event, playerSurface: var SurfacePtr,
                   window: var WindowPtr, renderer: var RendererPtr,
                       playing: var bool, playersPos: var Position): void =

  while event.pollEvent:
    case event.kind
      of KeyDown:
        let scancode = event.key.keysym.scancode

        if scancode == SDL_SCANCODE_Q:
          quitGame(surface = option(playerSurface), window = option(window),
                          renderer = option(renderer))
          playing = false

        if scancode == SDL_SCANCODE_D:
          window.setSurface

          playersPos.x += 10
          playersPos.y += 10

          var
            rect: Rect = (cint playersPos.x, cint playersPos.y,
                playerSurface.w, playerSurface.h)
            destRect = addr(rect)

          # Update the surface with the players new position
          playerSurface.blitSurface(nil, window.getSurface, destRect)

      of QuitEvent:
        quitGame(surface = option(playerSurface), window = option(window),
                 renderer = option(renderer))
        playing = false

      else: discard



when isMainModule:
  var
    playing = true
    window: WindowPtr = nil
    renderer: RendererPtr = nil
    playerSurface: SurfacePtr = nil
    event: Event
    playersPos: Position = (0, 0)

  initGame(window, renderer)

  while playing:
    # Without a delay the cpu would be at 100% while the game is running.
    sdl2.delay(5)
    handleEvents(event, playerSurface, window, renderer, playing, playersPos)

    if playing:
      if isNil(playerSurface):
        # NOTE: Executable needs to be ran from the directory that the image is in.
        playerSurface = sdl2.loadBMP("./player1.bmp")
        if isNil(playerSurface):
          logError("Error loading player image ")
        # Render image on to back buffer
        playerSurface.blitSurface(nil, window.getSurface, nil)

    # Update front buffer with back buffer
    if window.updateSurface == SdlError:
      logError("Error updating surface ")

