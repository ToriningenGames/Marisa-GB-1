# Marisa-GB-1
Simple exploration Touhou fangame for Gameboy

## Dependencies
<ul>
<li />Tiled (For map editing)
<li />WLA-GB v. 9 or greater (Used for game code assembly)
<li />WLA Link (Puts the game together)
<li />GNU Make (Build system)
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
Brings the hills to life with the sound of music. All text files. Edit away!

### Source
All the assembly files for the game's code. Other asm files can be included as same directory ("file.asm"), but resources are included as "rsc\name.ext"
Names are capitalized, except for the non-code .asm files for macros and the memory map. Since these are intended to be included, they're named to match.
This project leverages WLA's library abilities for almost every file; only Assemble.asm (containing the start and organization code) and vBlank2.asm (the screen's interrupt handlers) are compiled to objects.
I found including assembly files in assembly files to make building inefficient and difficult.

### Submakes
Stores the WLA generated Makefiles, so that dependencies are accurately reflected. Make sure you can make working builds before deleting! Due to a WLA bug, if some included files cannot be opened, the assembler issues an error, and doesn't output dependencies. GNU Make then blindly uses the created file, never bothering to update it.
If you change any includes, you must build, delete this directory, then build again, to ensure everything works like it should.
Man, I suck at Make.

### Tools
Helper programs needed to make the game, writtem by me.
- `MML6`: Music Macro Language compiler used for all the songs
- `Raw-MapConv`: Converts Tiled formatted maps into an uncompressed compiled format
- `LZifier`: LZ compresses data, used for maps and tiledata
There's also some miscy files here
- `specfile_marisa.cfg`: Tells LZifier the exact format of packets to output
- `Tiledata.tsx`: Copy of Tiledata.gb for Tiled, so game maps look right
- `System.tsx`: A few colored tiles, so Collsions, Priority, and Visibility bits can be visualized (and drawn)


### Root folder
Things I didn't know what to do with ended up here. Other than administrata, the linking file lives here. It can be safely deleted.
The Storyline.txt is not engine, data, or art related, so it doesn't have a home

## Building
- If you're not on Win64, build the tools in Tools
- Run `make` in the root folder
    - WLA not in your path? Use `make WLADIR=path/to/wla/dir`
    - Running Unix? Crack open the Makefile, do a find-replace from `\` to `/`, and replace the tooldefs in the first few Makefile lines

For right now, the Tools folder should be empty. This makes building the project very hard, as more than a few files get compiled to intermediate formats.
There is no workaround, no alternative, and the provided advice is to wait.

## Tips When Editiing
- The Makefile autogenerates the WLA linkfile as Link.link, adds all the pieces where they need to be, and throws it together.
- The two Make variables LIB0 and LIB1 place the libraries in banks 0 and 1. I tried to organize approximately on what would and would not be bankswitched, though it doesn't matter.
- The symbol file is stripped of section information automatically. This is done in the Makefile.
- It is encouraged, though not necessary, to ensure every resource has a compiled variant, so everything included is in Source or rsc.
- The tools are not very well documented here (left the documentation in the source). This will get fixed when the folder gets cleaned up.
- The Makefile is written on and for a Windows machine (line endings, commands, etc.). The executables are win64 binaries. The data of the project is fully portable.
- The Makefile should rebuild submakes when the source file changes, which, while costly, ensures they don't fall out of date. Additionally, it _should_ make Make build most the file's dependencies first.
    - Should something go wrong, or you add a new dependency, it is highly likely building will fail, because the Submake won't have it, but WLA refuses to output Make rules if it can't find all the file includes- which it won't, because they don't exist. The only recouse I know is to create dummy files, so the submakes can be remade, then delete the dummies so the files can be actually built. If anybody has a better solution to this chicken-egg problem, I'm all ears.
    - `make clean` does not delete the submake files

# TODO
Outside game:
<ul>
<li />[x] Organize the game files
<li />[x] Add `.gitignore`s for intermediate files
<li />[x] Move the tools away from the repo
<li />[ ] Add the music midis in
<li />[ ] Release the "picnic" demo
<li />[ ] Write a prereq script
</ul>
Inside game:
<ul>
<li />[ ] Debug cutscene elements to find which are crashing.
<li />[ ] Add Danmaku
<li />[ ] Add Reimu character behavior
<li />[ ] Add Reimu walking animations
<li />[ ] Add Narumi character behavior
<li />[ ] Add Alice character behavior
<li />[ ] Add Alice's other walking animations
<li />[ ] Add Fairy character behaviors
<li />[x] Add Fairy floaing animations
<li />[ ] Add text option to wait for button press
<li />[ ] Add some sort of character talk interation
<li />[ ] Create most more maps
<li />[ ] Write some title music
<li />[ ] Pare down unused utility functions
<li />[ ] Write all the cutscenes
</ul>
