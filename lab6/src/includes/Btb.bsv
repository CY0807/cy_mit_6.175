import Types::*;
import ProcTypes::*;
import RegFile::*;
import Vector::*;
import Ehr::*;

// indexSize is the number of bits in the index
interface Btb#(numeric type indexSize);
    method Addr predPc(Addr pc);
    method Action update(Addr thispc, Addr nextpc);
endinterface

// BTB use full tags, and should be only updated for BRANCH/JUMP instructions
// so it ALWAYS predicts pc+4 for NON-BRANCH instructions
module mkBtb( Btb#(indexSize) ) provisos( Add#(indexSize,a__,32), NumAlias#(TSub#(TSub#(AddrSz, 2), indexSize), tagSize) );
    Vector#(TExp#(indexSize), Reg#(Addr))          targets <- replicateM(mkReg(0));
    Vector#(TExp#(indexSize), Reg#(Bit#(tagSize)))    tags <- replicateM(mkReg(0));
    Vector#(TExp#(indexSize), Reg#(Bool))            valid <- replicateM(mkReg(False));

    function Bit#(indexSize) getIndex(Addr pc) = truncate(pc >> 2);
    function Bit#(tagSize) getTag(Addr pc) = truncateLSB(pc);

    method Addr predPc(Addr pc);
        let index = getIndex(pc);
        let tag = getTag(pc);

        if(valid[index] && (tag == tags[index])) begin
            return targets[index];
        end else begin
            return (pc + 4);
        end
    endmethod

    method Action update(Addr thisPc, Addr nextPc);
		let index = getIndex(thisPc);
		let tag = getTag(thisPc);
        if( nextPc != thisPc + 4 ) begin
            // update entry
            valid[index] <= True;
            tags[index] <= tag;
            targets[index] <= nextPc;
        end
		else if(tag == tags[index]) begin
			valid[index] <= False;
		end
    endmethod
endmodule


module mkBypassBtb( Btb#(indexSize) ) provisos( Add#(indexSize,a__,32), NumAlias#(TSub#(TSub#(AddrSz, 2), indexSize), tagSize) );
    Vector#(TExp#(indexSize), Ehr#(2,Addr))          targets <- replicateM(mkEhr(0));
    Vector#(TExp#(indexSize), Ehr#(2,Bit#(tagSize)))    tags <- replicateM(mkEhr(0));
    Vector#(TExp#(indexSize), Ehr#(2,Bool))            valid <- replicateM(mkEhr(False));

    function Bit#(indexSize) getIndex(Addr pc) = truncate(pc >> 2);
    function Bit#(tagSize) getTag(Addr pc) = truncateLSB(pc);

    method Addr predPc(Addr pc);
        let index = getIndex(pc);
        let tag = getTag(pc);

        if(valid[index][1] && (tag == tags[index][1])) begin
            return targets[index][1];
        end else begin
            return (pc + 4);
        end
    endmethod

    method Action update(Addr thisPc, Addr nextPc);
		let index = getIndex(thisPc);
		let tag = getTag(thisPc);
        if( nextPc != thisPc + 4 ) begin
            // update entry
            valid[index][0] <= True;
            tags[index][0] <= tag;
            targets[index][0] <= nextPc;
        end
		else if(tag == tags[index][0]) begin
			valid[index][0] <= False;
		end
    endmethod
endmodule