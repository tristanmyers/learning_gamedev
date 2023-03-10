import sdl2
import std/options

type
  Position = tuple[x, y: int]

  Entity = object of RootObj
    surface: SurfacePtr
    position: Position

  Player = object of Entity
    moveSpeed: int

  Game = object
    window: WindowPtr
    renderer: RendererPtr
    player: ref Player
    entity: ref Entity
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
  game.window = sdl2.createWindow(title = "Drawing some things",
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

proc movePlayer(x, y: int, game: ref Game): void =
  # setSurface(game)

  game.player.position.x += x
  game.player.position.y += y

  var
    rect: Rect = (cint game.player.position.x, cint game.player.position.y,
        game.player.surface.w, game.player.surface.h)
    destRect = addr(rect)

  # Update the surface with the players new position
  blitSurface(game.player.surface, nil, getSurface(game.window), destRect)

proc handleEvents(game: ref Game): void =
  while game.event.pollEvent:
    case game.event.kind
      of KeyDown:
        let scancode = game.event.key.keysym.scancode

        if scancode == SDL_SCANCODE_Q:
          quitGame(surface = option(game.player.surface), window = option(game.window),
                          renderer = option(game.renderer))
          game.playing = false

        if scancode == SDL_SCANCODE_D:
          movePlayer(1 * game.player.moveSpeed, 0, game)
        if scancode == SDL_SCANCODE_A:
          movePlayer(-1 * game.player.moveSpeed, 0, game)
        if scancode == SDL_SCANCODE_W:
          movePlayer(0, -1 * game.player.moveSpeed, game)
        if scancode == SDL_SCANCODE_S:
          movePlayer(0, 1 * game.player.moveSpeed, game)

      of QuitEvent:
        quitGame(surface = option(game.player.surface), window = option(game.window),
                 renderer = option(game.renderer))
        game.playing = false

      else: discard

when isMainModule:
  var
    game: ref Game = new(Game)

  game.window = nil
  game.renderer = nil
  game.player = new(Player)
  game.entity = new(Entity)
  game.playing = true

  game.player.surface = nil
  game.player.position = (0, 0)
  game.player.moveSpeed = 20

  game.entity.surface = nil
  game.entity.position = (0, 200)

  initGame(game)

  while game.playing:
    # Without a delay the cpu would be at 100% while the game is running.
    delay(5)
    handleEvents(game)

    if game.playing:
      if isNil(game.player.surface):
        # NOTE: Executable needs to be ran from the directory that the image is in because of this line.
        game.player.surface = loadBMP("./player1.bmp")
        if isNil(game.player.surface):
          logError("Error loading player image ")
        # Render image on to back buffer
        blitSurface(game.player.surface, nil, getSurface(game.window), nil)

      if isNil(game.entity.surface): 
        game.entity.surface = loadBMP("./entity.bmp")
        if isNil(game.entity.surface): 
          logError("Error loading entity image ")
        blitSurface(game.entity.surface, nil, getSurface(game.window), nil)

      # Update front buffer with back buffer
      if updateSurface(game.window) == SdlError:
          logError("Error updating window surface ")

