# Marisa-GB-1
Simple exploration Touhou fangame for Gameboy

## Dependencies
<ul>
<li />WLA-GB 9 or greater (Used for game code assembly)
<li />WLA Link (Puts the game together)
<li />GNU Make (Build system)
<li />Tiled 1.4.4 (For map editing)
</ul>

## Contained here

The file organization is pretty garbage, but I'll try to explain what I can.

### Art
Both concept art, and the tile data needed to make the game. Extension .gb so Tile Molester picks up on them with less fiddling.

### bin
ROM and symbol file end up here. Safe to delete.

### Faces
Tile data for the faces that appear in the text boxes in the game.

### lib
Folder for storing the built libraries during assembly. Safe to delete.

### Maps
Stores the Tiled maps that comprise all screens, alongside concept art.
- `Tiledata.tsx`: Copy of Tiledata.gb for Tiled, so game maps look right
- `System.tsx`: A few colored tiles, so Collsions, Priority, and Visibility bits can be visualized (and drawn)

### obj
Stores the compiled versions of the non-library files during assembly. Safe to delete.

### rsc
Stores the compiled versions of game assets. Safe to delete.

### Sound
Brings the hills to life with the sound of music. All text files. Edit away!
Midis for all (read: some) songs are also provided for your convenience.
The MML compiler is non-optimizing, so each song is hand optimized for size. *You have been warned.*

### Source
All the assembly files for the game's code. Other asm files can be included as same directory (`.include "file.asm"`), but resources are included as `.include "rsc\name.ext"`
Names are capitalized, except for the non-code .asm files for macros and the memory map. Since these are intended to be included, they're named to match.
This project leverages WLA's library abilities for almost every file; only Assemble.asm (containing the start and organization code) and vBlank2.asm (the screen's interrupt handlers) are compiled to objects.
I found including assembly files in assembly files to make building inefficient and difficult.

### Submakes
Stores the WLA generated Makefiles, so that dependencies are accurately reflected. Make sure you can make working builds before deleting! Due to a WLA bug, if some included files cannot be opened, the assembler issues an error, and doesn't output dependencies. GNU Make then blindly uses the created file, never bothering to update it.
If you change any includes, you must build, delete this directory, then build again, to ensure everything works like it should.
Man, I suck at Make.
This bug is fixed in more recent versions of WLA-DX. There's a tiiiiny window where it still ocurrs. My advice is to update WLA-DX.

### Tools
Helper programs needed to make the game, writtem by me.
- `MML6`: (My) Music Macro Language compiler used for all the songs
- `LZ-MapConv`: Converts Tiled 1.4.1 formatted maps into a compressed compiled format
- `LZifier`: LZ compresses data, used for faces and tiledata
There's also some miscy files here
- `specfile_marisa.cfg`: Tells LZifier the exact format of packets to output


### Root folder
Things I didn't know what to do with ended up here. Other than administrata, the linking file lives here. It can be safely deleted.
The Storyline.txt is not engine, data, or art related, so it doesn't have a home

## Building
- If you're not on Win64, build the tools in Tools (tools not included sorry)
- Run `make` in the root folder
    - WLA not in your path? Use `make WLADIR=path/to/wla/dir`
    - Running Unix? Crack open the Makefile, do a find-replace from `\` to `/`. Also redefine the commands specified near line 10
    - Dependent tools not in `Tools`? Use `make TOOLDIR=path/to/tools`
    - Build environment won't check out, but you know it'll be OK anyways? Use `make force`
    - `make clean` is available for you
    - The Makefile has a few memory maps available for you. Building alone may not leave enough space, but using `make MAP=ALTMAP` ekes out a few extra bytes. If you're adding things in and know it's over size, use `make MAP=FATMAP`. *The game will not run using this map!*

For right now, the Tools folder contains win64 versions of tools I writ. `make` and `wla` will have to be provided by you.
The tools' sources are available in other repositories.

## Tips When Editiing
- The Makefile autogenerates the WLA linkfile as Link.link, adds all the pieces where they need to be, and throws it together.
- The two Make variables LIB0 and LIB1 place the libraries in banks 0 and 1. I tried to organize approximately on what would and would not be bankswitched, though it doesn't matter, because the project is 32k. (This can be thrown out the window with the altername memory maps)
- The symbol file is stripped of section information automatically. This is done in the Makefile.
- It is encouraged, though not necessary, to ensure every resource has a compiled variant, so everything included is in Source or rsc.
- The tools are not very well documented here (left the documentation in the source). This will get fixed in the distant future.
- The Makefile is written on and for a Windows machine (line endings, commands, etc.). The executables are win64 binaries. The data of the project is probably portable.
- The Makefile should rebuild submakes when the source file changes, which, while costly, ensures they don't fall out of date. Additionally, it _should_ make Make build most the file's dependencies first.
- I dislike Make and disagree with how it does things and sees the world, so I likely have done a few things incorrectly there. If some change doesn't seem to be sticking, suspect the Makefile.

# TODO
Outside game:
<ul>
<li />[x] Organize the game files
<li />[x] Add `.gitignore`s for intermediate files
<li />[x] Move the tools away from the repo
<li />[ ] Add the music midis in
<li />[x] Release the "picnic" demo
<li />[ ] Write a prereq script
<li />[ ] Release video?
</ul>
Inside game:
<ul>
<li />[x] Finish the last half-dozen cutscenes
<li />[x] Script and write the last half-dozen text blobs
<li />[x] Tie the cutscenes into the game at their intended points
<li />[x] Rewrite Love-Colored Master Spark to be more fitting and smaller
<li />[x] Rewrite the fairy behavior to be more RAM based and modular
<li />[x] Reimplement danmaku
<li />[x] Write up patterns for the fairies
<li />[x] Write up patterns for Narumi
<li />[x] Tie the patterns to their characters
<li />[x] Clean up Narumi fight
<li />~~[ ] Redo collision to be more robust and less slow!~~
<li />[ ] Give up on optimizing collision speed and find a way to accept lag
<li />[ ] Add the hat interaction
<li />[x] Add danmaku to the second ending
<li />[x] Make danmaku animated
</ul>
