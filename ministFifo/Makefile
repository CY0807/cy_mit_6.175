
all: compile conflict pipeline bypass cfnc cf

compile:
	mkdir -p buildDir
	sudo chmod 777 -R buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions -keep-fires TestBench.bsv

pipeline: compile
	bsc -sim -e mkTbPipelineFunctional -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simPipelineFunctional
	bsc -sim -e mkTbPipelineScheduling -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simPipelineScheduling

bypass: compile
	bsc -sim -e mkTbBypassFunctional -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simBypassFunctional
	bsc -sim -e mkTbBypassScheduling -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simBypassScheduling

cf: compile
	bsc -sim -e mkTbCFFunctional -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simCFFunctional
	bsc -sim -e mkTbCFScheduling -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simCFScheduling

verilog: compile
	bsc -verilog -g mkBypassFifo -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions -keep-fires ministFifo.bsv
	bsc -verilog -g mkPipelineFifo -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions -keep-fires ministFifo.bsv
	bsc -verilog -g mkCFFifo -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions -keep-fires ministFifo.bsv

clean:
	rm -rf buildDir sim*
