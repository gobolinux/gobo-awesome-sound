gobo-awesome-sound
==================

A PulseAudio sound widget for Awesome WM, designed for [http://gobolinux.org](GoboLinux).

Requirements
------------

* Awesome 3.5+
* PulseAudio
* a terminal-based PulseAudio mixer (`ncpamixer` by default) and a terminal (`urxvt` by default)
* `lode-fonts` for a nice-looking mixer pop-up :-) (only used with urxvt)

Using
-----

Require the module:


```lua
local sound = require("gobo.awesome.sound")
```

Create the widget with `sound.new()`:

```lua
local sound_widget = sound.new()
```

You can use a different terminal mixer

```lua
local sound_widget = sound.new({mixer="pulsemixer"})
```

Then add it to your layout.
In a typical `rc.lua` this will look like this:


```lua
right_layout:add(sound.new())
```

Additionally, add keybindings for your multimedia keys:

```lua
   awful.key({ }, "XF86AudioRaiseVolume", function() sound_widget:set_volume(5, "+") end,
      {description = "Raise audio volume", group = "multimedia"}
   ),
   awful.key({ }, "XF86AudioLowerVolume", function() sound_widget:set_volume(5, "-") end,
      {description = "Lower audio volume", group = "multimedia"}
   ),
   awful.key({ }, "XF86AudioMute",        function() sound_widget:toggle_mute() end,
      {description = "Toggle mute", group = "multimedia"}
   ),
```
