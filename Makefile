#Must be first line!
FILENAME := $(lastword $(MAKEFILE_LIST))

DEL = del 2>NUL
QUIET = @
GREP = findstr /v " SECTION" $(subst /,\,$(addsuffix .sym,$(basename $(OUT))))
MV = move >NUL

LIB0 = $(addprefix lib/,task.lib OAM2.lib Actor.lib memory.lib CORDIC2.lib \
	Pause.lib Sound.lib sndEffect.lib Text.lib LCD_IRQ_assist.lib Extract.lib \
	Face.lib chara.lib Cutscenes.lib Fairy.lib )
LIB1 = $(addprefix lib/,graphics.lib Songs.lib Maps.lib effects.lib \
	TextStrings.lib Narumi.lib Alice.lib Reimu.lib ) 
LINK = Link.link
OBJ = $(addprefix obj/,Assemble.obj vBlank2.obj)
SUPP = TileData.lzc
SONGS = Spark2.mcs NULL.mcs
MAPS = $(addprefix Maps/,Test.gbm Debug.gbm Hall.gbm)
OUT = Assemble.gb

all : $(SUPP) $(SONGS) $(MAPS) $(OBJ) $(LIB0) $(LIB1) $(LINK)
	wlalink -v -S -r $(LINK) $(OUT)
#Prettify the symbol output (No section boundry labels!)
	$(QUIET)$(GREP) > ~tempsym
	$(QUIET)$(DEL) $(addsuffix .sym,$(basename $(OUT)))
	$(QUIET)$(MV) ~tempsym $(addsuffix .sym,$(basename $(OUT)))
	$(QUIET)$(DEL) ~tempsym

Submakes/%.obj.d :
	wla-gb -M -o obj/$(notdir $(basename $@)) $(notdir $(addsuffix .asm,$(basename $(basename $@)))) > $@
Submakes/%.lib.d :
	wla-gb -M -l lib/$(notdir $(basename $@)) $(notdir $(addsuffix .asm,$(basename $(basename $@)))) > $@
include $(addprefix Submakes/,$(addsuffix .d,$(LIB0)))
include $(addprefix Submakes/,$(addsuffix .d,$(LIB1)))
include $(addprefix Submakes/,$(addsuffix .d,$(OBJ)))

obj/%.obj : %.asm Submakes/obj/%.obj.d
	wla-gb -v -x -o $@ $<
lib/%.lib : %.asm Submakes/lib/%.lib.d
	wla-gb -v -x -l $@ $<
%.mcs : %.mml
	MML6.exe -i=$< -o=$@ -t=gb
%.hcd : %.gb
	huffencoder2.exe $< $@
Maps/%.gbm : Maps/%.tmx
	Maps\Raw-MapConv.exe $< $@.raw
	Maps\LZifier.exe LZ77 specfile_marisa.txt $@.raw $@
%.lzc : %.gb specfile_marisa.txt
	LZifier.exe LZ77 specfile_marisa.txt $< $@
$(LINK) : $(FILENAME)
	$(file > $(LINK),[objects])
	$(foreach I, $(OBJ),$(file >> $(LINK), $(I)))
	$(file >> $(LINK),[libraries])
	$(foreach I, $(LIB0), $(file >> $(LINK),BANK 0 SLOT 0 $(I)))
	$(foreach I, $(LIB1), $(file >> $(LINK),BANK 1 SLOT 1 $(I)))

.PHONY : clean
clean :
	$(QUIET)$(DEL) $(subst /,\,$(OBJ))
	$(QUIET)$(DEL) $(subst /,\,$(LIB0))
	$(QUIET)$(DEL) $(subst /,\,$(LIB1))
	$(QUIET)$(DEL) $(subst /,\,$(LINK))
	$(QUIET)$(DEL) $(subst /,\,$(SUPP))
	$(QUIET)$(DEL) $(subst /,\,$(MAPS))
	$(QUIET)$(DEL) $(subst /,\,$(SONGS))
	$(QUIET)$(DEL) $(subst /,\,$(OUT))

FORCE:
