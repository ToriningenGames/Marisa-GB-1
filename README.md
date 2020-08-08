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

The file organization is pretty garbage, but I'll try to explain what I can

### Archive
Before I started tracking this on GitHub, I would copy files to this directory before making big changes. And sometimes randomly. Old stuff here.

### Faces
Tile data for the faces that appear in the text boxes in the game. Also stores the compressed versions when building.

### lib
Folder for storing the built libraries during assembly. Safe to delete.

### Maps
Stores the Tiled maps that comprise all screens, as well as their compiled versions.

### obj
Stores the compiled versions of the non-library files during assembly. Safe to delete.

### Submakes
Stores the WLA generated Makefiles, so that dependencies are accurately reflected. Make sure you can make working builds before deleting! Due to a WLA bug, if some included files cannot be opened, the assembler issues an error, and doesn't output dependencies. GNU Make then blindly uses the created file, never bothering to update it.
If you change any includes, you must build, delete this directory, then build again, to ensure everything works like it should.
Man, I suck at Make.

### Testsuite
Supposedly small subprograms made to test new libraries as they're written. As the game got more complete (and I got a little better at development), I don't use this much anymore.

### Root folder
Here, generally, are all the source files, songs, tools, concept art, and other miscy needed to build the game. For laziness reasons, many things aren't sorted into folders like they **should** be. Maybe later.
Also included are some helpful information files on Gameboy-ey things, like the Sound Mapping Table.
The light smattering of xml files are for Notepad++, so it can properly highlight WLA syntax.

# TODO
Outside game:
<ul>
<li />[ ] Organize the game files
<li />[ ] Add `.gitignore`s for intermediate files
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
