TOOLDIR = Tools
WLAGB = $(if $(WLADIR),$(WLADIR)\\,)wla-gb.exe
WLALINK = $(if $(WLADIR),$(WLADIR)\\,)wlalink.exe
MML = $(if $(TOOLDIR),$(TOOLDIR)\\,)MML6.exe
MAPCONV = $(if $(TOOLDIR),$(TOOLDIR)\\,)LZ-MapConv.exe
LZ = $(if $(TOOLDIR),$(TOOLDIR)\\,)LZifier.exe
SPECFILE = $(if $(TOOLDIR),$(TOOLDIR)\\,)specfile_marisa.cfg

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

LIB0 = Task.lib OAM2.lib Actor.lib Face.lib SndEffect.lib Sound.lib Memory.lib \
	LCD_IRQ_Assist.lib Extract.lib Chara.lib Exits.lib Camera.lib Graphics.lib \
	Reimu.lib Narumi.lib Alice.lib Fairy.lib Pause.lib Effects.lib SinCos.lib \
	TextStrings.lib Text.lib Hitboxes.lib
LIB1 = Maps.lib Songs.lib Cutscenes.lib
LINK = Link.link
OBJ = Assemble.obj vBlank2.obj
SUPP = TileData.lzc
SONGS = Spark2.mcs NULL.mcs
MAPS = Test.gbm Debug.gbm Hall.gbm
OUT = bin\Assemble.gb
SYM = $(subst /,\,$(addsuffix .sym,$(basename $(OUT))))

.PHONY : all clean check
all : check $(OUT)

$(OUT) : $(OBJ) $(LIB0) $(LIB1) $(LINK) | bin
	$(WLALINK) -v -S -r $(LINK) $(OUT)
#Prettify the symbol output (No section boundry labels!)
	$(QUIET)$(GREP) > ~tempsym
	$(QUIET)$(RM) $(SYM)
	$(QUIET)$(MV) ~tempsym $(SYM)

%.obj.d : $(WLAGB) ..\..\%.asm | Submakes Submakes\obj
	$(WLAGB) -M -I Source -o $(notdir $(basename $@)) $(addprefix Source\,$(notdir $(addsuffix .asm,$(basename $(basename $@))))) > Submakes\obj\$(@F)
%.lib.d : $(WLAGB) ..\..\%.asm | Submakes Submakes\lib
	$(WLAGB) -M -I Source -l $(notdir $(basename $@)) $(addprefix Source\,$(notdir $(addsuffix .asm,$(basename $(basename $@))))) > Submakes\lib\$(@F)
include $(addprefix Submakes\lib\,$(addsuffix .d,$(LIB0)))
include $(addprefix Submakes\lib\,$(addsuffix .d,$(LIB1)))
include $(addprefix Submakes\obj\,$(addsuffix .d,$(OBJ)))

%.obj : %.asm %.obj.d $(WLAGB) | obj
	$(WLAGB) -v -x -I $(<D) -o obj\$@ $<
%.lib : %.asm %.lib.d $(WLAGB) | lib
	$(WLAGB) -v -x -I $(<D) -l lib\$@ $<
%.gbm : ..\%.tmx $(MAPCONV) | rsc
	$(MAPCONV) $< $@
%.lzc : ..\%.gb $(SPECFILE) $(LZ) | rsc
	$(LZ) LZ77 $(word 2,$^) $< $@
%.mcs : ..\%.mml $(MML) | rsc
	$(MML) -i=$< -o=$@ -t=gb
$(LINK) : Makefile
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), obj/$(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB0), $(file >> $(LINK),BANK 0 SLOT 0 lib/$(I)))
	$(foreach I, $(LIB1), $(file >> $(LINK),BANK 1 SLOT 1 lib/$(I)))

bin obj lib rsc Submakes Submakes\obj Submakes\lib:
	mkdir $@

#Ensure the build environment is sane
check :
ifeq ("$(wildcard $(WLAGB))","")
	$(error Missing GB-Z80 compiler)
else ifeq ("$(wildcard $(WLALINK))","")
	$(error Missing WLA linker)
else ifeq ("$(wildcard $(MML))","")
	$(error Missing MML compiler)
else ifeq ("$(wildcard $(LZ))","")
	$(error Missing LZ compresser)
else ifeq ("$(wildcard $(MAPCONV))","")
	$(error Missing map converter)
else ifeq ("$(wildcard $(SPECFILE))","")
	$(error Missing LZ specfile)
endif
	$(info Build environment OK)

clean :
	$(QUIET)$(RM) obj
	$(QUIET)$(RM) lib
	$(QUIET)$(RM) rsc
	$(QUIET)$(RM) $(subst /,\,$(LINK))
	$(QUIET)$(RM) bin

FORCE:
