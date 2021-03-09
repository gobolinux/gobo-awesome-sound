
local sound = {}

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local timer = gears.timer or timer
local lgi = require("lgi")
local cairo = lgi.require("cairo")
local mouse = mouse

local function pread(cmd)
   local pd = io.popen("LANG=C " .. cmd, "r")
   if not pd then
      return ""
   end
   local data = pd:read("*a")
   pd:close()
   return data
end

local function update_state(state, output)
   local active = false
   state.volume = 0
   state.mute = false
   for line in output:gmatch("[^\n]+") do
      local k, v = line:match("^%s*([^:]*): (.*)")
      if k == "index" then
         active = false
      elseif k == "* index" then
         active = true
         state.sink = v
      elseif active then
         if k == "volume" then
            local percent = v:match("front.-([0-9]*)%%")
            state.volume = tonumber(percent) or 0
         elseif k == "muted" then
            state.mute = (v == "yes")
         end
      end
   end
   if not (state.sink and state.volume) then
      state.valid = false
      return
   end
end

local function update(state)
   update_state(state, pread("pacmd list-sinks"))
end

local function draw_handle(surface, volume)
   local cr = cairo.Context(surface)
   local ctm = cr:get_matrix()
   local r = volume < 50 and ((50 - volume) / 50) * -135
                                or ((volume - 50) / 50) * 135
   cr:set_source_rgb(0.2, 0.2, 0.2)
   cr:translate(65, 50)
   cr:rotate(math.rad(r))
   local px, py = 0, -15
   local pat = cairo.Pattern.create_radial(px, py, 0, px, py, 30)
   pat:add_color_stop_rgb(0, 0.2, 0.2, 0.2)
   pat:add_color_stop_rgb(1, 0.6, 0.6, 0.6)
   cr:set_source(pat)
   cr:rotate(math.rad(-r))
   cr:translate(-15, 0)
   cr:rotate(math.rad(r))
   cr:arc(0, -15, 10, 0, math.rad(360))
   cr:set_matrix(ctm)
   cr:fill()
end

local function darken_pixel(hex_color, start, finish)
   darker_pixel = string.format("%x", math.floor(tonumber(string.sub(hex_color, start, finish), 16) * 0.4))
   if (string.len(darker_pixel) < 2) then
      darker_pixel = "0"..darker_pixel
   end
   return darker_pixel
end

local function darken_color(hex_color)
   r = darken_pixel(hex_color, 2, 3)
   g = darken_pixel(hex_color, 4, 5)
   b = darken_pixel(hex_color, 6, 7)
   darker_color = "#"..r..g..b
   return darker_color
end

local function draw_lights(surface, state, options)
   local cr = cairo.Context(surface)

   local arc_width = options and options.arc_width or 5
   local arc_mute = options and options.arc_mute or "#ff0000"
   local arc_fg = options and options.arc_fg or "#00ffff"
   local arc_fg_darker = darken_color(arc_fg)
   local arc_bg = options and options.arc_bg or arc_fg_darker or "#006666"
   local ctm = cr:get_matrix()

   cr:translate(50, 50)
   cr:rotate(math.rad(-90))

   local stop = state.mute and 100 or state.volume
   local r = stop < 50 and ((50 - stop) / 50) * -135
                                or ((stop - 50) / 50) * 135

   cr:set_line_width(arc_width)
   if state.mute == true then
      cr:set_source_rgb(gears.color.parse_color(arc_mute))
   else
      cr:set_source_rgb(gears.color.parse_color(arc_bg))
      cr:arc(0, 0, 42, math.rad(-135), math.rad(135))
      cr:stroke()
      cr:set_source_rgb(gears.color.parse_color(arc_fg))
   end
   cr:arc(0, 0, 42, math.rad(-135), math.rad(r))
   cr:stroke()

   cr:set_matrix(ctm)
end

local function draw_icon(surface, state, options)

   local cr = cairo.Context(surface)

   local px, py = 0, 50
   local pat = cairo.Pattern.create_radial(px, py, 0, px, py, 100)
   pat:add_color_stop_rgb(0, 0.2, 0.2, 0.2)
   pat:add_color_stop_rgb(1, 0.6, 0.6, 0.6)
   cr:set_source(pat)
   cr:arc(50, 50, 30, 0, math.rad(360))
   cr:fill()

   draw_lights(surface, state, options)

   draw_handle(surface, state.volume)

end

local function update_icon(widget, state, options)
   local image = cairo.ImageSurface("ARGB32", 100, 100)
   draw_icon(image, state, options)
   widget:set_image(image)
end

function sound.new(options)
   local mixer = options and options.mixer or "ncpamixer"
   local terminal = options and options.terminal or "urxvt"

   local widget = wibox.widget.imagebox()
   local state = {
      valid = false,
      volume = 0,
      mute = false
   }

   widget.set_volume = function (self, val, delta)
      local volume = state.volume
      if delta == "+" then
         volume = math.min(volume + val, 100)
      elseif delta == "-" then
         volume = math.max(0, volume - val)
      end
      update_state(state, pread("pactl set-sink-volume " .. state.sink .. " " .. volume .. "%; pacmd list-sinks"))
      update_icon(self, state, options)
   end

   widget.toggle_mute = function(self)
      local setting = state.mute and "no" or "yes"
      update_state(state, pread("pactl set-sink-mute " .. state.sink .. " " .. setting .. "; pacmd list-sinks"))
      update_icon(self, state, options)
   end

   local widget_timer = timer({timeout=5})
   widget_timer:connect_signal("timeout", function()
      update(state)
      update_icon(widget, state, options)
   end)
   widget_timer:start()
   widget:buttons(awful.util.table.join(
      awful.button({ }, 1, function()
         widget:toggle_mute()
      end),
      awful.button({ }, 3, function()
         local x = mouse.screen.geometry.width - 800
         local y = 24
         local killed = false
         for c in awful.client.iterate(function (c) return c.name == mixer end, nil, mouse.screen) do
            c:kill()
            killed = true
         end
         if not killed then
            if (terminal == "urxvt") then
               awful.util.spawn("urxvt -geometry 100x20+"..x.."+"..y.." -cr green -title "..mixer.." -fn '*-lode sans mono-*' -fb '*-lode sans mono-*' -fi '*-lode sans mono-*' -fbi '*-lode sans mono-*' -depth 32 --color0 rgba:2F00/3F00/3F00/e000 -bg rgba:2F00/3F00/3F00/e000 --color4 '#2F3F3F' --color6 '#8aa' --color11 '#2ee' --color14 '#acc' -b 0 +sb -e "..mixer) -- or whatever your preferred sound mixer is
            else
               awful.util.spawn(terminal.." -g 100x20+"..x.."+"..y.." -T "..mixer.." -e "..mixer.."")
         end
            local t
            t = timer.start_new(0.3, function()
               for c in awful.client.iterate(function (c) return c.name == mixer end, nil, mouse.screen) do
                  c:connect_signal("unfocus", function(cl) cl:kill() end)
               end
               t:stop()
            end)
         end
      end),
      awful.button({ }, 4, function()
         widget:set_volume(5, "+")
      end),
      awful.button({ }, 5, function()
         widget:set_volume(5, "-")
      end)
   ))
   update(state)
   update_icon(widget, state, options)
   widget:connect_signal("mouse::enter", function() update(state) end)
   return widget
end

return sound
