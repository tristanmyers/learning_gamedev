import sdl2
import std/options

type
  Position = tuple[x, y: int]

  Player = object
    surface: SurfacePtr
    position: Position
    moveSpeed: int

  Game = object
    window: WindowPtr
    renderer: RendererPtr
    player: ref Player
    playing: bool
    event: Event

var
  purple: Color = (r: uint8 0x66, g: uint8 0x04, b: uint8 0x9b,
      a: uint8 SDL_ALPHA_OPAQUE)
  green: Color = (r: uint8 0x51, g: uint8 0xad, b: uint8 0x6a,
      a: uint8 SDL_ALPHA_OPAQUE)
  yellow: Color = (r: uint8 0xde, g: uint8 0xfc, b: uint8 0x8d,
      a: uint8 SDL_ALPHA_OPAQUE)

proc logError(msg: string): void = stderr.writeLine(msg, sdl2.getError())

proc setSurface(game: ref Game): void =
  let screenSurface = getSurface(game.window)
  let surfaceFill = screenSurface.fillRect(nil, mapRGB(screenSurface.format,
      green.r, green.g, green.b))
  if surfaceFill == SdlError: logError("Error filling surface rect ")

proc initGame(game: ref Game): void =
  if sdl2.init(INIT_VIDEO) == SdlError:
    logError("Error intializing sdl2 ")

  # This is also creating a surface the same size as the window.
  game.window = sdl2.createWindow(title = "Handling some events",
      x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED, w = 800, h = 600,
      flags = SDL_WINDOW_SHOWN)
  if isNil(game.window):
    logError("Error creating window ")

  setSurface(game)

# NOTE: Maybe window and renderer doesn't need to be passed through as params, they maybe me something like getWindow
# I think having optional parameters is more appoproiate here than procedure overrides since there is not much logic difference
proc quitGame(window: Option[WindowPtr], renderer: Option[RendererPtr],
    surface: Option[SurfacePtr]): void =
  if surface.isSome(): sdl2.freeSurface(get(surface))
  if renderer.isSome(): sdl2.destroy(get(renderer))
  if window.isSome(): sdl2.destroy(get(window))

  sdl2.quit()

proc movePlayer(x, y: int, window: WindowPtr, playerSurface: SurfacePtr,
    playersPos: var Position): void =
  # window.setSurface

  playersPos.x += x
  playersPos.y += y

  var
    rect: Rect = (cint playersPos.x, cint playersPos.y,
        playerSurface.w, playerSurface.h)
    destRect = addr(rect)

  # Update the surface with the players new position
  playerSurface.blitSurface(nil, window.getSurface, destRect)

# TODO: Is there a better way to set these parameters?
proc handleEvents(event: var Event, playerSurface: SurfacePtr,
                   window: WindowPtr, renderer: RendererPtr,
                       playing: var bool, playersPos: var Position,
                           playerMoveSpeed: int): void =
# proc handleEvents(game: ref Game): void =

  while event.pollEvent:
    case event.kind
      of KeyDown:
        let scancode = event.key.keysym.scancode

        if scancode == SDL_SCANCODE_Q:
          quitGame(surface = option(playerSurface), window = option(window),
                          renderer = option(renderer))
          playing = false

        if scancode == SDL_SCANCODE_D:
          movePlayer(1 * playerMoveSpeed, 0, window, playerSurface, playersPos)
        if scancode == SDL_SCANCODE_A:
          movePlayer(-1 * playerMoveSpeed, 0, window, playerSurface, playersPos)
        if scancode == SDL_SCANCODE_W:
          movePlayer(0, -1 * playerMoveSpeed, window, playerSurface, playersPos)
        if scancode == SDL_SCANCODE_S:
          movePlayer(0, 1 * playerMoveSpeed, window, playerSurface, playersPos)


      of QuitEvent:
        quitGame(surface = option(playerSurface), window = option(window),
                 renderer = option(renderer))
        playing = false

      else: discard

when isMainModule:
  var
    # playing = true
    # window: WindowPtr = nil
    # renderer: RendererPtr = nil
    # playerSurface: SurfacePtr = nil
    # playerMoveSpeed: int = 20
    # event: Event
    # playersPos: Position = (0, 0)

    player: ref Player = new(Player)
    game: ref Game = new(Game)

  player.surface = nil
  player.position = (0, 0)
  player.moveSpeed = 20

  game.window = nil
  game.renderer = nil
  game.player = player
  game.playing = true

  initGame(game)

  while game.playing:
    # Without a delay the cpu would be at 100% while the game is running.
    sdl2.delay(5)
    handleEvents(game)

    if game.playing:
      var playerSurface = game.player.surface
      if isNil(playerSurface):
        # NOTE: Executable needs to be ran from the directory that the image is in.
        playerSurface = sdl2.loadBMP("./player1.bmp")
        if isNil(playerSurface):
          logError("Error loading player image ")
        # Render image on to back buffer
        playerSurface.blitSurface(nil, getSurface(game.window), nil)

    # TODO: video subsystem isn't initializing?
    # Update front buffer with back buffer
    if updateSurface(game.window) == SdlError:
      logError("Error updating surface ")

