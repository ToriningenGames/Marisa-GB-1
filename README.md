# Marisa-GB-1
Simple exploration Touhou fangame for Gameboy

## Dependencies
<ul>
<li />Tiled
<li />WLA-GB v. 9 or greater
<li />WLA Link
<li />GNU Make
</ul>

## Contained here

The file organization is pretty garbage, but I'll try to explain what I can.

### Archive
Before I started tracking this on GitHub, I would copy files to this directory before making big changes. And sometimes randomly. Old stuff here.

### Art
Both concept art, and the tile data needed to make the game. Extension .gb so Tile Molestor picks up on them with less fiddling.

### bin
ROM and symbol file end up here. Safe to delete.

### Faces
Tile data for the faces that appear in the text boxes in the game.

### lib
Folder for storing the built libraries during assembly. Safe to delete.

### Maps
Stores the Tiled maps that comprise all screens, alongside concept art.

### obj
Stores the compiled versions of the non-library files during assembly. Safe to delete.

### rsc
Stores the compiled versions of game assets. Safe to delete.

### Sound

### Source
All the assembly files for the game's code. Other asm files can be included as same directory ("file.asm"), but resources are included as "rsc\name.ext"
Names are capitalized, except for the non-code .asm files for macros and the memory map. Since these are intended to be included, they're named to match.
This project leverages WLA's library abilities for almost every file; only Assemble.asm (containing the start and organization code) and vBlank2.asm (the screen's interrupt handlers) are compiled to objects.
I found including assembly files in assembly files to make building inefficient and difficult.

### Submakes
Stores the WLA generated Makefiles, so that dependencies are accurately reflected. Make sure you can make working builds before deleting! Due to a WLA bug, if some included files cannot be opened, the assembler issues an error, and doesn't output dependencies. GNU Make then blindly uses the created file, never bothering to update it.
If you change any includes, you must build, delete this directory, then build again, to ensure everything works like it should.
Man, I suck at Make.

### Testsuite
Supposedly small subprograms made to test new libraries as they're written. As the game got more complete (and I got a little better at development), I don't use this much anymore, as the tests became just part of the game.

### Tools
Every external program needed to make the game, including my tools, WLA, and even `make`. Config files for these tools are also here. Probably highly illegal-this directory will remain empty on GitHub until I sort out what can and cannot live here.

### Root folder
Here, generally, are all the source files, songs, tools, concept art, and other miscy needed to build the game. For laziness reasons, many things aren't sorted into folders like they **should** be. Maybe later.
Also included are some helpful information files on Gameboy-ey things, like the Sound Mapping Table.
The light smattering of xml files are for Notepad++, so it can properly highlight WLA syntax.

## Building
- Gather your prerequisites in Tools
- Run `make`

For right now, the Tools folder should be empty. This makes building the project very hard, as more than a few files get compiled to intermediate formats.
There is no workaround, no alternative, and the provided advice is to wait.

## Tips When Editiing
- The Makefile autogenerates the WLA linkfile as Link.link, adds all the pieces where they need to be, and throws it together.
- The two Make variables LIB0 and LIB1 place the libraries in banks 0 and 1. I tried to organize approximately on what would and would not be bankswitched, though it doesn't matter.
- The symbol file is stripped of section information automatically. This is done in the Makefile.
- It is encouraged, though not necessary, to ensure every resource has a compiled variant, so everything included is in Source or rsc.
- The tools are not very well documented here (left the documentation in the source). This will get fixed when the folder gets cleaned up.
- The Makefile is written on and for a Windows machine (line endings, commands, etc.). The executables are win64 binaries. The data of the project is fully portable.
- If you're having issues with the submakes being out of date, build, then delete them, then build again! If you can't build, becuase they're out of date, you can either A: edit them by hand, or B: create dummy files where they're expected to be.
    - If anybody knows how to wire GNU Make up correctly to handle updating submakes _without_ human intervention, I'm all ears.

# TODO
Outside game:
<ul>
<li />[x] Organize the game files
<li />[x] Add `.gitignore`s for intermediate files
<li />[ ] Move the tools away from the repo
<li />[ ] Add the music midis in
<li />[ ] Release the "picnic" demo
</ul>
Inside game:
<ul>
<li />[ ] Debug cutscene elements to find which are crashing.
<li />[ ] Add Danmaku
<li />[ ] Add Reimu character behavior
<li />[ ] Add Narumi character behavior
<li />[ ] Add Alice character behavior
<li />[ ] Add Fairy character behaviors
<li />[ ] Create most more maps
<li />[ ] Write some title music
<li />[ ] Pare down unused utility functions
<li />[ ] Write all the cutscenes
</ul>
