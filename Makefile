#Programs we use to build
TOOLDIR = Tools
WLAGB = $(if $(WLADIR),$(WLADIR)\,)wla-gb.exe
WLALINK = $(if $(WLADIR),$(WLADIR)\,)wlalink.exe
MML = $(if $(TOOLDIR),$(TOOLDIR)\,)MML6.exe
MAPCONV = $(if $(TOOLDIR),$(TOOLDIR)\,)LZ-MapConv.exe
LZ = $(if $(TOOLDIR),$(TOOLDIR)\,)LZifier.exe
SPECFILE = $(if $(TOOLDIR),$(TOOLDIR)\,)specfile_marisa.cfg

#Shell commands we use to build
RM = del /Q 2>NUL
QUIET = @
GREP = findstr /v " SECTION" $(SYM)
MV = move >NUL
WHICH = where 2>NUL

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
vpath %.obj.d .\Submakes\obj
vpath %.lib.d .\Submakes\lib

LIB0 = $(addprefix lib\,\
	Task.lib OAM2.lib Actor.lib Face.lib SndEffect.lib Sound.lib Memory.lib \
	LCD_IRQ_Assist.lib Extract.lib Chara.lib Exits.lib Camera.lib Graphics.lib \
	Reimu.lib Narumi.lib Alice.lib Fairy.lib Pause.lib Effects.lib SinCos.lib \
	TextStrings.lib Text.lib Hitboxes.lib)
LIB1 = $(addprefix lib\,\
	Maps.lib Songs.lib Cutscenes.lib)
LINK = Link.link
OBJ = $(addprefix obj\,Assemble.obj vBlank2.obj)
SUPP = rsc\TileData.lzc
OUT = bin\Assemble.gb
SYM = $(addsuffix .sym,$(basename $(OUT)))


.PHONY : all clean check force
all : check force
force : $(OUT)

$(OUT) : $(OBJ) $(LIB0) $(LIB1) $(LINK) | bin
	$(WLALINK) -v -S -r $(LINK) $(OUT)
#Prettify the symbol output (No section boundry labels!)
	$(QUIET)$(GREP) > ~tempsym
	$(QUIET)$(RM) $(SYM)
	$(QUIET)$(MV) ~tempsym $(SYM)

Submakes\obj\\%.obj.d : %.asm | Submakes Submakes\obj
	$(WLAGB) -M -I Source -o $(notdir $(addsuffix .obj,$(basename $<))) $< > $@
Submakes\lib\\%.lib.d : %.asm | Submakes Submakes\lib
	$(WLAGB) -M -I Source -l $(notdir $(addsuffix .obj,$(basename $<))) $< > $@
include $(addprefix Submakes\,$(addsuffix .d,$(LIB0)))
include $(addprefix Submakes\,$(addsuffix .d,$(LIB1)))
include $(addprefix Submakes\,$(addsuffix .d,$(OBJ)))

obj\\%.obj : %.asm %.obj.d | obj
	$(WLAGB) -v -x -I $(<D) -o $@ $<
lib\\%.lib : %.asm %.lib.d | lib
	$(WLAGB) -v -x -I $(<D) -l $@ $<
rsc\\%.gbm : %.tmx | rsc
	$(MAPCONV) $< $@
rsc\\%.lzc : %.gb $(SPECFILE) | rsc
	$(LZ) LZ77 $(word 2,$^) $< $@
rsc\\%.mcs : %.mml | rsc
	$(MML) -i=$< -o=$@ -t=gb
$(LINK) : Makefile
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), $(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB0), $(file >> $(LINK),BANK 0 SLOT 0 $(I)))
	$(foreach I, $(LIB1), $(file >> $(LINK),BANK 1 SLOT 1 $(I)))

bin obj lib rsc Submakes Submakes\obj Submakes\lib:
	mkdir $@

#Ensure the build environment is sane
check :
ifeq (, $(shell $(WHICH) $(WLAGB)))
  ifeq ("$(wildcard $(WLAGB))","")
	$(error Missing GB-Z80 compiler)
  endif
else ifeq (, $(shell $(WHICH) $(WLALINK)))
  ifeq ("$(wildcard $(WLALINK))","")
	$(error Missing WLA linker)
  endif
else ifeq (, $(shell $(WHICH) $(MML)))
  ifeq ("$(wildcard $(MML))","")
	$(error Missing MML compiler)
  endif
else ifeq (, $(shell $(WHICH) $(LZ)))
  ifeq ("$(wildcard $(LZ))","")
	$(error Missing LZ compresser)
  endif
else ifeq (, $(shell $(WHICH) $(MAPCONV)))
  ifeq ("$(wildcard $(MAPCONV))","")
	$(error Missing map converter)
  endif
else ifeq (, $(shell $(WHICH) $(SPECFILE)))
  ifeq ("$(wildcard $(SPECFILE))","")
	$(error Missing LZ specfile)
  endif
endif
	$(info Build environment OK)

clean :
	$(RM) obj
	$(RM) lib
	$(RM) rsc
	$(RM) $(LINK)
	$(RM) bin

