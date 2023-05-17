# RobCo Industries (TM) Termlink Emulator
The emulator of the RobCo Termlink from Fallout 4

Features:
- full configurable json config
- page by page navigation
- termlink hacking
- execute external programs
- open text pages

Documentation:
- main.json
- - main // entry point
- - main.name // title of the entry point
- - main.data // menu items of the entry point
- - main.hack // if isset, required to hack
- item
- - item.name // visual name
- - item.exec // execute external command
- - item.page // goto a specific page
- hack
- - hack.pass // password
- - hack.data // words presented in bytes showcase 0x0000 .... 0xFFFF

The trademarks RobCo and RobCo Industries are owned by Bethesda Softworks All rights reserved.
