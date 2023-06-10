fifo:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions  -show-range-conflict Fifo.bsv
	bsc -sim -e mkTestBenchFifo -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/simFifo
	./buildDir/simFifo

inelastic:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions  -show-range-conflict Fft.bsv
	bsc -sim -e mkTbFftInelastic -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/simInelastic
	./buildDir/simInelastic

elastic:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions  -show-range-conflict Fft.bsv
	bsc -sim -e mkTbFftInelastic -bdir buildDir -info-dir buildDir -simdir buildDir -o buildDir/simElastic
	./buildDir/simElastic

all: fifo inelastic elastic

clean:
	rm -rf buildDir sim* *.vcd

.PHONY: clean all add compile
.DEFAULT_GOAL := all