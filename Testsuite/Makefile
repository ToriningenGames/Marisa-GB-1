DEL = del 2>NUL
QUIET = @

OUT = CORDICTest.gb
LINK = CORDICTest.link
LIB = CORDIC2.lib

CORDICTest = CORDIC2.lib

CORDICTest : CORDICTest.obj CORDICTest.link $(CORDICTest)
	wlalink -v -S -r CORDICTest.link CORDICTest.gb
%.link : %.obj
	$(file > $@,[objects]) 
	$(file >> $@,$<)
	$(file >> $@,[libraries])
	$(foreach O,$($*),$(file >> $@,BANK 0 SLOT 0 $O))
%.obj : %.asm
	wla-gb -v -o $@ $<
%.lib : %.asm
	wla-gb -v -l $@ $<
%.mcs : %.mml
	MML6.exe -i=$< -o=$@ -t=gb
%.hcd : %.gb
	huffencoder2.exe $< $@
%.gbm : %.tmx
	MapConv.exe $< $@
%.obj : ../%.asm
	wla-gb -v -o $@ $<
%.lib : ../%.asm
	wla-gb -v -l $@ $<
%.mcs : ../%.mml
	MML6.exe -i=$< -o=$@ -t=gb
%.hcd : ../%.gb
	huffencoder2.exe $< $@
%.gbm : ../%.tmx
	MapConv.exe $< $@

.PHONY : clean
clean :
	$(QUIET)$(DEL) $(OBJ)
	$(QUIET)$(DEL) $(OUT)
