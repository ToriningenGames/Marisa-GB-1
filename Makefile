
RM = del /Q 2>NUL
QUIET = @
GREP = findstr /v " SECTION" $(SYM)
MV = move >NUL

#Source files
vpath %.asm .\Source
#Art/Face files
vpath %.gb .\Faces .\Art
#MML music files
vpath %.mml .\Sound
#Config files for tools
vpath %.cfg .\Tools
#Map files
vpath %.tmx .\Maps
#Hypothetical sound effects here


#Compiled intermediaries
vpath %.obj .\obj
vpath %.lib .\lib
vpath %.lzc .\rsc
vpath %.raw .\rsc
vpath %.mcs .\rsc
vpath %.gbm .\rsc

#Submakes
vpath %.d ./Submakes/obj ./Submakes/lib

TOOLDIR = Tools
WLADIR = 

LIB0 = Task.lib OAM2.lib Actor.lib Memory.lib CORDIC2.lib Fairy.lib Face.lib \
	Pause.lib Sound.lib SndEffect.lib Text.lib LCD_IRQ_Assist.lib Extract.lib \
	Chara.lib Cutscenes.lib
LIB1 = Graphics.lib Songs.lib Maps.lib Effects.lib TextStrings.lib Reimu.lib \
	Narumi.lib Alice.lib
LINK = Link.link
OBJ = Assemble.obj vBlank2.obj
SUPP = TileData.lzc
SONGS = Spark2.mcs NULL.mcs
MAPS = Test.gbm Debug.gbm Hall.gbm
OUT = bin/Assemble.gb
SYM = $(subst /,\,$(addsuffix .sym,$(basename $(OUT))))
SPECFILE = Tools/specfile_marisa.cfg

.PHONY : all
all : $(OUT)

$(OUT) : $(OBJ) $(LIB0) $(LIB1) $(LINK) | bin
	$(WLADIR)/wlalink -v -S -r $(LINK) $(OUT)
#Prettify the symbol output (No section boundry labels!)
	$(QUIET)$(GREP) > ~tempsym
	$(QUIET)$(RM) $(SYM)
	$(QUIET)$(MV) ~tempsym $(SYM)

%.obj.d : | Submakes Submakes\obj
	$(WLADIR)\wla-gb -M -I Source -o $(notdir $(basename $@)) $(addprefix Source\,$(notdir $(addsuffix .asm,$(basename $(basename $@))))) > $@
%.lib.d : | Submakes Submakes\lib
	$(WLADIR)\wla-gb -M -I Source -l $(notdir $(basename $@)) $(addprefix Source\,$(notdir $(addsuffix .asm,$(basename $(basename $@))))) > $@
include $(addprefix Submakes/lib/,$(addsuffix .d,$(LIB0)))
include $(addprefix Submakes/lib/,$(addsuffix .d,$(LIB1)))
include $(addprefix Submakes/obj/,$(addsuffix .d,$(OBJ)))

%.obj : %.asm %.obj.d | obj
	$(WLADIR)\wla-gb -v -x -I $(<D) -o obj\$@ $<
%.lib : %.asm %.lib.d | lib
	$(WLADIR)\wla-gb -v -x -I $(<D) -l lib\$@ $<
%.raw : ..\%.tmx | rsc
	$(TOOLDIR)\Raw-MapConv.exe $< $@
%.gbm : $(SPECFILE) %.raw | rsc
	$(TOOLDIR)\LZifier.exe LZ77 $^ $@
%.lzc : $(SPECFILE) ..\%.gb | rsc
	$(TOOLDIR)\LZifier.exe LZ77 $^ $@
%.mcs : ..\%.mml | rsc
	$(TOOLDIR)\MML6.exe -i=$< -o=$@ -t=gb
$(LINK) : $(FILENAME)
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), obj/$(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB0), $(file >> $(LINK),BANK 0 SLOT 0 lib/$(I)))
	$(foreach I, $(LIB1), $(file >> $(LINK),BANK 1 SLOT 1 lib/$(I)))

bin obj lib rsc Submakes Submakes\obj Submakes\lib:
	mkdir $@

.PHONY : resources
resources : 
# Make a file for every resource. Needed for WLA to generate makefiles so make knows to build those resources
# No stomping

.PHONY : clean
clean :
	$(QUIET)$(RM) obj
	$(QUIET)$(RM) lib
	$(QUIET)$(RM) rsc
	$(QUIET)$(RM) $(subst /,\,$(LINK))
	$(QUIET)$(RM) bin

FORCE:
