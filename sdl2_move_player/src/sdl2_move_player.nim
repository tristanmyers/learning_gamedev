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

proc initGame(window: var WindowPtr, renderer: var RendererPtr,
    screenSurface: var SurfacePtr): void =
  if sdl2.init(INIT_VIDEO) == SdlError:
    logError("Error intializing sdl2 ")

  # This is also creating a surface the same size as the window.
  window = sdl2.createWindow(title = "Handling some events",
      x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED, w = 800, h = 600,
      flags = SDL_WINDOW_SHOWN)
  if isNil(window):
    logError("Error creating window ")

  renderer = sdl2.createRenderer(window, cint -1, Renderer_Accelerated)
  if isNil(renderer): logError("Error creating renderer ")

  screenSurface = window.getSurface
  let surfaceFill = fillRect(screenSurface, nil, mapRGB(screenSurface.format, green.r, green.g, green.b))
  if surfaceFill == SdlError: logError("Error filling surface rect ")
  discard window.updateSurface

# NOTE: Maybe window and renderer doesn't need to be passed through as params, they maybe me something like getWindow
# I think having optional parameters is more appoproiate here than procedure overrides since there is not much logic difference
proc quitGame(window: Option[WindowPtr], renderer: Option[RendererPtr],
    surface: Option[SurfacePtr], texture: Option[TexturePtr]): void =
  if texture.isSome(): sdl2.destroy(get(texture))
  if surface.isSome(): sdl2.freeSurface(get(surface))
  if renderer.isSome(): sdl2.destroy(get(renderer))
  if window.isSome(): sdl2.destroy(get(window))

  sdl2.quit()

# TODO: Is there a better way to set these parameters?
proc handleEvents(event: var Event, playerSurface: var SurfacePtr,
                  playerTexture: var TexturePtr, window: var WindowPtr, renderer: var RendererPtr, playing: var bool, playersPrevPos: var Position): void =

  # if isNil(playerTexture): playerTexture = sdl2.createTextureFromSurface(renderer, playerSurface)

  while event.pollEvent:
    case event.kind
      of KeyDown:
        let scancode = event.key.keysym.scancode

        if scancode == SDL_SCANCODE_Q:
          quitGame(surface = option(playerSurface), window = option(window),
                          renderer = option(renderer), texture = option(playerTexture))
          playing = false

        if scancode == SDL_SCANCODE_D:
          playersPrevPos.x += 10
          playersPrevPos.y += 10

          var
            rect: Rect = (cint playersPrevPos.x, cint playersPrevPos.y, playerSurface.w, playerSurface.h)
            destRect = addr(rect)
            
          renderer.copy(playerTexture, nil, destRect)

      of QuitEvent:
        quitGame(surface = option(playerSurface), window = option(window),
                 renderer = option(renderer), texture = option(playerTexture))
        playing = false

      else: discard



when isMainModule:
  var
    playing = true
    window: WindowPtr = nil
    renderer: RendererPtr = nil
    screenSurface: SurfacePtr = nil
    playerSurface: SurfacePtr = nil
    playerTexture: TexturePtr = nil
    event: Event
    playersPrevPos: Position = (0, 0)

  initGame(window, renderer, screenSurface)
  renderer.clear

  while playing:
    # Without a delay the cpu would be at 100% while the game is running.
    sdl2.delay(5)
    handleEvents(event, playerSurface, playerTexture, window, renderer, playing, playersPrevPos)

    if playing:
      if isNil(playerSurface):
        stdout.writeLine("loaded image")
        # NOTE: Executable needs to be ran from the directory that the image is in.
        playerSurface = sdl2.loadBMP("./player1.bmp")
        if isNil(playerSurface):
          logError("Error loading player image ")
        # Render image on to back buffer
        # sdl2.blitSurface(playerSurface, nil, screenSurface, nil)
        # Update front buffer with back buffer
        # if window.updateSurface == SdlError:
          # logError("Error updating surface ")

      renderer.present

