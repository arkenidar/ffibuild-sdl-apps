-- github.com/CapsAdmin/ffibuild test app for libSDL2
--------------------------------------------------------

-- tomblind.local-lua-debugger-vscode
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local ffi = require("ffi")

local SDL = require("SDL2")

SDL.Log("%s\n", "https://github.com/CapsAdmin/ffibuild test app for libSDL2")
-- https://github.com/arkenidar/ffibuild-sdl-luajit (my fork)

function SDL.new_SDL_Rect()
  return ffi.new("struct SDL_Rect")
end

function SDL.new_SDL_Event()
  return ffi.new("union SDL_Event")
end

SDL.Init(SDL.e.INIT_VIDEO)
local window = SDL.CreateWindow("title", 50, 50, 400, 300, 0)
local window_surface = SDL.GetWindowSurface(window)

function image_load(name)
  local file = SDL.RWFromFile(name .. ".bmp", "rb")
  return SDL.LoadBMP_RW(file, 1)
end

function image_transparency(image_surface, rgb)
  local key = SDL.MapRGB(window_surface.format, rgb[1], rgb[2], rgb[3])
  SDL.SetColorKey(image_surface, SDL.e.TRUE, key)
end

function rect_from_xywh(xywh)
  if xywh == nil then return nil end
  local rect = SDL.new_SDL_Rect()
  rect.x = xywh[1]
  rect.y = xywh[2]
  rect.w = xywh[3]
  rect.h = xywh[4]
  return rect
end

function surface_draw_rect(rgb, xywh)
  SDL.FillRect(window_surface, rect_from_xywh(xywh), SDL.MapRGB(window_surface.format, rgb[1], rgb[2], rgb[3]))
end

function surface_draw_image(image_surface, xywh)
  SDL.UpperBlitScaled(image_surface, nil, window_surface, rect_from_xywh(xywh))
end

local image_surface = image_load("transparence")
local rgb = { 0, 0, 255 } -- key color (blue is transparent)
image_transparency(image_surface, rgb)

local event = SDL.new_SDL_Event()
local looping = true

local movement = 0

while looping do
  -- update (before draw)

  while SDL.PollEvent(event) ~= 0 do
    if event.type == SDL.e.KEYDOWN and event.key.keysym.scancode == SDL.e.SCANCODE_RIGHT then
      movement = movement + 10
    elseif event.type == SDL.e.KEYDOWN and event.key.keysym.scancode == SDL.e.SCANCODE_LEFT then
      movement = movement - 10
    end

    if event.type == SDL.e.QUIT
        or event.type == SDL.e.KEYDOWN
        and event.key.keysym.scancode == SDL.e.SCANCODE_ESCAPE
    then
      -- exit
      looping = false
      break
    end
    --]]
  end
  if not looping then break end

  -- draw (after update)

  surface_draw_rect({ 255, 255, 255 }) -- draw-begin: clear

  local rgb = { 255, 255, 0 }
  local xywh = { 0, 0, 100, 100 }

  surface_draw_rect(rgb, xywh)

  xywh[1] = xywh[1] + xywh[3] + movement -- image put aside
  surface_draw_image(image_surface, xywh)

  SDL.UpdateWindowSurface(window) -- draw-end: present
end

SDL.FreeSurface(image_surface)

SDL.Quit()
