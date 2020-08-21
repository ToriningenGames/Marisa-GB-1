#Must be first line!
FILENAME := $(lastword $(MAKEFILE_LIST))

DEL = del /Q 2>NUL
QUIET = @
GREP = findstr /v " SECTION" $(SYM)
MV = move >NUL
TOOLDIR = Tools

#Source files
vpath %.asm .\Source
#Art/Face files
vpath %.gb .\Art .\Faces
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

$(OUT) : $(SUPP) $(SONGS) $(MAPS) $(OBJ) $(LIB0) $(LIB1) $(LINK)
	$(TOOLDIR)/wlalink -v -S -r $(LINK) $(OUT)
#Prettify the symbol output (No section boundry labels!)
	$(QUIET)$(GREP) > ~tempsym
	$(QUIET)$(DEL) $(SYM)
	$(QUIET)$(MV) ~tempsym $(SYM)

%.obj.d :
	$(TOOLDIR)\wla-gb -M -o obj/$(notdir $(basename $@)) $(notdir $(addsuffix .asm,$(basename $(basename $@)))) > $@
%.lib.d :
	$(TOOLDIR)\wla-gb -M -l lib/$(notdir $(basename $@)) $(notdir $(addsuffix .asm,$(basename $(basename $@)))) > $@
include $(addprefix Submakes/lib/,$(addsuffix .d,$(LIB0)))
include $(addprefix Submakes/lib/,$(addsuffix .d,$(LIB1)))
include $(addprefix Submakes/obj/,$(addsuffix .d,$(OBJ)))

%.obj : %.asm %.obj.d
	$(TOOLDIR)\wla-gb -v -x -I $(<D) -o obj\$@ $<
%.lib : %.asm %.lib.d
	$(TOOLDIR)\wla-gb -v -x -I $(<D) -l lib\$@ $<
%.mcs : %.mml
	$(TOOLDIR)\MML6.exe -i=$< -o=rsc/$@ -t=gb
#%.hcd : %.gb
#	$(TOOLDIR)\huffencoder2.exe $< rsc/$@
%.raw : %.tmx
	$(TOOLDIR)\Raw-MapConv.exe $< rsc/$@
%.gbm : $(SPECFILE) %.raw
	$(TOOLDIR)\LZifier.exe LZ77 $^ rsc/$@
%.lzc : $(SPECFILE) %.gb
	$(TOOLDIR)\LZifier.exe LZ77 $^ rsc/$@
$(LINK) : $(FILENAME)
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), obj/$(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB0), $(file >> $(LINK),BANK 0 SLOT 0 lib/$(I)))
	$(foreach I, $(LIB1), $(file >> $(LINK),BANK 1 SLOT 1 lib/$(I)))

.PHONY : clean
clean :
	$(QUIET)$(DEL) obj
	$(QUIET)$(DEL) lib
	$(QUIET)$(DEL) rsc
	$(QUIET)$(DEL) $(subst /,\,$(LINK))
	$(QUIET)$(DEL) bin

FORCE:
