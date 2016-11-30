gobo-awesome-sound
==================

An ALSA sound widget for Awesome WM, designed for [http://gobolinux.org](GoboLinux).

Requirements
------------

* Awesome 3.5+
* `amixer` (from alsa-utils)
* `alsamixer` and `urxvt` for mixer pop-up
* `lode-fonts` for a nice-looking mixer pop-up :-)

Using
-----

Require the module:


```
local sound = require("gobo.awesome.sound")
```

Create the widget with `sound.new()`:

```
local sound_widget = sound.new()
```

Then add it to your layout.
In a typical `rc.lua` this will look like this:


```
right_layout:add(sound.new())
```

Additionally, add keybindings for your multimedia keys:

```
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

