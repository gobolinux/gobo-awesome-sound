package = "gobo-awesome-sound"
version = "scm-1"
source = {
   url = "git+https://github.com/gobolinux/gobo-awesome-sound.git"
}
description = {
   detailed = "An ALSA sound widget for Awesome WM, designed for [http://gobolinux.org](GoboLinux).",
   homepage = "https://github.com/gobolinux/gobo-awesome-sound",
   license = "MIT"
}
dependencies = {}
build = {
   type = "builtin",
   modules = {
      ["gobo.awesome.sound"] = "gobo/awesome/sound.lua"
   }
}
