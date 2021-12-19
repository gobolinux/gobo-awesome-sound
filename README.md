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

Also a different terminal

```lua
local sound_widget = sound.new({mixer="pulsemixer", terminal="xterm"})
```

If you use the global `terminal` variable on `rc.lua` you can set it like this

```lua
local sound_widget = sound.new({mixer="pulsemixer", terminal=terminal})
```

there are other configurable options
Variable | Description | Type | Default Value
--- | --- | --- | ---
`arc_width` | width of the icon arc | integer | 5
`arc_fg` | foreground color of the icon arc | string (hex) | "#00ffff"
`arc_bg` | background color of the icon arc | string (hex) | "#006666"
`arc_mute` | color of the icon arc when mute | string (hex) | "#ff0000"
`device_type` | choose type of pulse device to control (sink or source) | string | "sink"

note: if you set arc_fg but not arc_bg a 60% darker shade of the arc_fg color will be calculated and used for arc_bg

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
Note: make sure to use the correct syntax for the version of awesome you are using
