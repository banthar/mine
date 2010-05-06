
OUTPUT:=mine

SOURCES:=$(shell find -iname "*.hx")
PACKAGES:=
HXFLAGS:=-swf-header 720:480:30:0 -swf-version 10

debug: $(OUTPUT)_debug.swf

release: $(OUTPUT).swf

$(OUTPUT)_debug.swf: $(SOURCES) assets.swf
	haxe $(PACKAGES) -debug -D network-sandbox -main Main -swf-lib assets.swf $(HXFLAGS) -swf9 $@

$(OUTPUT).swf: $(SOURCES) assets.swf
	haxe $(PACKAGES) -main Main -swf-lib assets.swf $(HXFLAGS) -swf9 $@

ASSETS:=$(shell find data)

data/images.swf: data/images.svg data/images.xml
	swfmill simple data/images.xml data/images.swf

assets.swf: $(ASSETS) data/images.swf resources.xml
	SamHaXe resources.xml assets.swf

run: $(OUTPUT)_debug.swf.swf
	flashplayer $(OUTPUT)-debug.swf.swf

clean:
	rm -rf assets.swf data/images.swf
