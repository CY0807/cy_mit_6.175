mymkdir:
	mkdir -p buildDir
	chmod 777 -R buildDir

mux: mymkdir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Multiplexer.bsv
	bsc -sim -e mkTbMux -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/simMux
	./buildDir/simMux

muxsimple: mymkdir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Multiplexer.bsv
	bsc -sim -e mkTbMuxSimple -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/simMuxSimple
	./buildDir/simMuxSimple

rca: mymkdir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Adders.bsv
	bsc -sim -e mkTbRCAdder -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/rca
	./buildDir/rca

rcasimple: mymkdir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Adders.bsv
	bsc -sim -e mkTbRCAdderSimple -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/rcasimple
	./buildDir/rcasimple

csa: mymkdir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Adders.bsv
	bsc -sim -e mkTbCSAdder -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/csa
	./buildDir/csa

csasimple: mymkdir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Adders.bsv
	bsc -sim -e mkTbCSAdderSimple -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/csasimple
	./buildDir/csasimple

bs: mymkdir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions BarrelShifter.bsv
	bsc -sim -e mkTbBS -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/simBs
	./buildDir/simBs

all: mux muxsimple rca rcasimple csa csasimple bs

clean:
	rm -rf buildDir sim* *.vcd

.PHONY: clean all add compile
.DEFAULT_GOAL := all