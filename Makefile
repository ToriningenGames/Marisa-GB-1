
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
vpath %.d .\Submakes\obj .\Submakes\lib

TOOLDIR = Tools
WLADIR = 

LIB0 = Task.lib OAM2.lib Actor.lib Face.lib SndEffect.lib Sound.lib Memory.lib \
	LCD_IRQ_Assist.lib Extract.lib Chara.lib Exits.lib Camera.lib Graphics.lib \
	Reimu.lib Narumi.lib Alice.lib Fairy.lib Pause.lib Effects.lib SinCos.lib \
	TextStrings.lib Text.lib
LIB1 = Maps.lib Songs.lib Cutscenes.lib
LINK = Link.link
OBJ = Assemble.obj vBlank2.obj
SUPP = TileData.lzc
SONGS = Spark2.mcs NULL.mcs
MAPS = Test.gbm Debug.gbm Hall.gbm
OUT = bin\Assemble.gb
SYM = $(subst /,\,$(addsuffix .sym,$(basename $(OUT))))
SPECFILE = Tools/specfile_marisa.cfg

.PHONY : all
all : $(OUT)

$(OUT) : $(OBJ) $(LIB0) $(LIB1) $(LINK) | bin
	$(WLADIR)\wlalink -v -S -r $(LINK) $(OUT)
#Prettify the symbol output (No section boundry labels!)
	$(QUIET)$(GREP) > ~tempsym
	$(QUIET)$(RM) $(SYM)
	$(QUIET)$(MV) ~tempsym $(SYM)

%.obj.d : $(WLADIR)\wla-gb.exe ..\..\%.asm | Submakes Submakes\obj
	$(WLADIR)\wla-gb -M -I Source -o $(notdir $(basename $@)) $(addprefix Source\,$(notdir $(addsuffix .asm,$(basename $(basename $@))))) > Submakes\obj\$(@F)
%.lib.d : $(WLADIR)\wla-gb.exe ..\..\%.asm | Submakes Submakes\lib
	$(WLADIR)\wla-gb -M -I Source -l $(notdir $(basename $@)) $(addprefix Source\,$(notdir $(addsuffix .asm,$(basename $(basename $@))))) > Submakes\lib\$(@F)
include $(addprefix Submakes\lib\,$(addsuffix .d,$(LIB0)))
include $(addprefix Submakes\lib\,$(addsuffix .d,$(LIB1)))
include $(addprefix Submakes\obj\,$(addsuffix .d,$(OBJ)))

%.obj : %.asm %.obj.d $(WLADIR)\wla-gb.exe | obj
	$(WLADIR)\wla-gb -v -x -I $(<D) -o obj\$@ $<
%.lib : %.asm %.lib.d $(WLADIR)\wla-gb.exe | lib
	$(WLADIR)\wla-gb -v -x -I $(<D) -l lib\$@ $<
%.gbm : ..\%.tmx $(TOOLDIR)\LZ-MapConv.exe | rsc
	$(TOOLDIR)\LZ-MapConv.exe $< $@
# Alt way to compile maps, using raw+lzifier
# Does not support tile transparency
#%.raw : ..\%.tmx | rsc
#	$(TOOLDIR)\Raw-MapConv.exe $< $@
#%.gbm : $(SPECFILE) %.raw | rsc
#	$(TOOLDIR)\LZifier.exe LZ77 $^ $@
%.lzc : ..\%.gb $(SPECFILE) $(TOOLDIR)\LZifier.exe | rsc
	$(TOOLDIR)\LZifier.exe LZ77 $(word 2,$^) $< $@
%.mcs : ..\%.mml $(TOOLDIR)\MML6.exe | rsc
	$(TOOLDIR)\MML6.exe -i=$< -o=$@ -t=gb
$(LINK) : Makefile
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
