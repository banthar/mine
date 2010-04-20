
OUTPUT:=mine

SOURCES:=$(shell find -iname "*.hx")
PACKAGES:=
HXFLAGS:=-swf-header 720:480:30:0 -swf-version 10 -D network-sandbox

$(OUTPUT).swf: $(SOURCES) assets.swf
	haxe $(PACKAGES) -debug -main Main -swf-lib assets.swf $(HXFLAGS) -swf9 $@

ASSETS:=$(shell find data)

data/images.swf: data/images.svg data/images.xml
	swfmill simple data/images.xml data/images.swf

assets.swf: $(ASSETS) data/images.swf resources.xml
	SamHaXe resources.xml assets.swf

run: $(OUTPUT).swf
	flashplayer $(OUTPUT).swf

clean:
	rm -rf assets.swf data/images.swf
