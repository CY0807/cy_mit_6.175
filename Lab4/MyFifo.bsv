import Ehr::*;
import Vector::*;

/* Exercise 1 
Implement mkMyConflictFifo in MyFifo.bsv. You can build and run the functional testbench by running
$ make conflict
$ ./simConflictFunctional
There is no scheduling testbench for this module because enq and deq are expected to conflict.
*/

// Fifo interface 
interface Fifo#(numeric type n, type t);
    method Bool notFull;
    method Action enq(t x);
    method Bool notEmpty;
    method Action deq;
    method t first;
    method Action clear;
endinterface

// Conflict FIFO
module mkMyConflictFifo(Fifo#(n, t)) provisos (Bits#(t,tSz));
    Vector#(n, Reg#(t))     data     <- replicateM(mkRegU());
    Reg#(Bit#(TLog#(n)))    enqP     <- mkReg(0);
    Reg#(Bit#(TLog#(n)))    deqP     <- mkReg(0);
    Reg#(Bool)              empty    <- mkReg(True);
    Reg#(Bool)              full     <- mkReg(False);

    Bit#(TLog#(n))          max_index = fromInteger(valueOf(n)-1);

    method Bool notFull;
        return !full;
    endmethod

    method Action enq(t x) if (full==False);

        Bit#(TLog#(n)) newP = 0;
        if (enqP == max_index) begin
            newP = 0;
        end else begin
            newP = enqP + 1;
        end
        enqP <= newP;
        full <= (newP == deqP);
        empty <= False;
        data[enqP] <= x;
    endmethod

    method Bool notEmpty;
        return !empty;
    endmethod

    method Action deq if (empty==False);
        Bit#(TLog#(n)) newP = 0;
        if (deqP == max_index) begin
            newP = 0;
        end else begin
            newP = deqP + 1;
        end
        deqP <= newP;

        empty <= (newP == enqP);
        full <= False;
    endmethod

    method t first if (empty==False);
        return data[deqP];
    endmethod

    method Action clear;
        enqP <= 0;
        deqP <= 0;
        empty <= True;
        full <= False;
    endmethod
endmodule

/* Exercise 2
Implement mkMyPipelineFifo and mkMyBypassFifo in MyFifo.bsv using EHRs and the method mentioned above. You can build the functional and scheduling testbenches for the pipeline FIFO and the bypass FIFO by running
$ make pipeline
$ make bypass
respectively. If these compile with no scheduling warning, then the scheduling testbench passed and the two FIFOs have the expected scheduling behavior. To test their functionality against reference implementations you can run
$ ./simPipelineFunctional
$ ./simBypassFunctional
If you are having trouble implementing clear with the correct schedule and functionality, you can remove it from the tests temporarily by setting has_clear to false in the associated modules in TestBench.bsv.
*/

// Pipeline FIFO
module mkMyPipelineFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    Vector#(n, Reg#(t)) data <- replicateM(mkRegU());
    Ehr#(3,Bit#(TLog#(n))) enqP <- mkEhr(0);
    Ehr#(3,Bit#(TLog#(n))) deqP <- mkEhr(0);
    Ehr#(3,Bool) empty <- mkEhr(True);
    Ehr#(3,Bool) full <- mkEhr(False);
    Bit#(TLog#(n)) max_index = fromInteger(valueOf(n)-1);

    method Bool notFull;
        return !full[1];
    endmethod

    method Action enq(t x) if (full[1]==False);
        Bit#(TLog#(n)) newP = 0;
        if (enqP[1] == max_index) begin
            newP = 0;
        end else begin
            newP = enqP[1] + 1;
        end
        enqP[1] <= newP;
        full[1] <= (newP == deqP[1]);
        empty[1] <= False;
        data[enqP[1]] <= x;
    endmethod

    method Bool notEmpty;
        return !empty[0];
    endmethod

    method Action deq if (empty[0]==False);
        Bit#(TLog#(n)) newP = 0;
        if (deqP[0] == max_index) begin
            newP = 0;
        end else begin
            newP = deqP[0] + 1;
        end
        deqP[0] <= newP;
        empty[0] <= (newP == enqP[0]);
        full[0] <= False;
    endmethod

    method t first if (empty[0]==False);
        return data[deqP[0]];
    endmethod

    method Action clear;
        enqP[2] <= 0;
        deqP[2] <= 0;
        empty[2] <= True;
        full[2] <= False;
    endmethod
endmodule

// Bypass FIFO
module mkMyBypassFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    Vector#(n, Ehr#(2, t)) data <- replicateM(mkEhrU());
    Ehr#(3,Bit#(TLog#(n))) enqP <- mkEhr(0);
    Ehr#(3,Bit#(TLog#(n))) deqP <- mkEhr(0);
    Ehr#(3,Bool) empty <- mkEhr(True);
    Ehr#(3,Bool) full <- mkEhr(False);
    Bit#(TLog#(n)) max_index = fromInteger(valueOf(n)-1);

    method Bool notFull;
        return !full[0];
    endmethod

    method Action enq(t x) if (full[0]==False);
        Bit#(TLog#(n)) newP = 0;
        if (enqP[0] == max_index) begin
            newP = 0;
        end else begin
            newP = enqP[0] + 1;
        end
        enqP[0] <= newP;
        full[0] <= (newP == deqP[0]);
        empty[0] <= False;
        data[enqP[0]][0] <= x;
    endmethod

    method Bool notEmpty;
        return !empty[1];
    endmethod

    method Action deq if (empty[1]==False);
        Bit#(TLog#(n)) newP = 0;
        if (deqP[1] == max_index) begin
            newP = 0;
        end else begin
            newP = deqP[1] + 1;
        end
        deqP[1] <= newP;

        empty[1] <= (newP == enqP[1]);
        full[1] <= False;
    endmethod

    method t first if (empty[1]==False);
        return data[deqP[1]][1];
    endmethod

    method Action clear;
        enqP[2] <= 0;
        deqP[2] <= 0;
        empty[2] <= True;
        full[2] <= False;
    endmethod
endmodule

/* Exercise 3
Implement mkMyCFFifo as described above without the clear method. You can build the functional and scheduling testbenches by running
$ make cfnc
If these compile with no scheduling warning, then the scheduling testbench passed and the enq and deq methods of the FIFO can be scheduled in any order. (It is fine to have a warning saying that rule m_maybe_clear has no action and will be removed.) You can run the functional testbench by running
$ ./simCFNCFunctional
*/

// Confilc Free FIFO Without Clear
module mkMyCFNCFifo(Fifo#(n, t)) provisos (Bits#(t,tSz));
    Vector#(n, Reg#(t)) data <- replicateM(mkRegU());
    Reg#(Bit#(TLog#(n))) enqP <- mkReg(0);
    Reg#(Bit#(TLog#(n))) deqP <- mkReg(0);
    Reg#(Bool) empty <- mkReg(True);
    Reg#(Bool) full <- mkReg(False);
    Ehr#(2, Bool) deqReq <- mkEhr(False);
    Ehr#(2, Maybe#(t)) enqReq <- mkEhr(tagged Invalid);
    Bit#(TLog#(n)) max_index = fromInteger(valueOf(n)-1);

    (* no_implicit_conditions *)
    (* fire_when_enabled *)
    rule canonicalize (True);
        deqReq[1] <= False;
        enqReq[1] <= tagged Invalid;

        Bit#(TLog#(n)) newdeqP = 0;
        if (deqP == max_index) begin
            newdeqP = 0;
        end else begin
            newdeqP = deqP + 1;
        end

        Bit#(TLog#(n)) newenqP = 0;
        if (enqP == max_index) begin
            newenqP = 0;
        end else begin
            newenqP = enqP + 1;
        end

        case (tuple2(enqReq[1], deqReq[1])) matches
            {tagged Valid .dat, True}: begin
                enqP <= newenqP;
                deqP <= newdeqP;
                data[enqP] <= dat;
            end
            {tagged Valid .dat, False}: begin
                enqP <= newenqP;
                data[enqP] <= dat;
                full <= (newenqP == deqP);
                empty <= False;
            end
            {tagged Invalid, True}: begin
                deqP <= newdeqP;
                empty <= (newdeqP == enqP);
                full <= False;
            end
            default: begin end
        endcase      
    endrule

    method Bool notFull;
        return !full;
    endmethod

    method Action enq(t x) if (full==False);
        enqReq[0] <= tagged Valid x; 
    endmethod

    method Bool notEmpty;
        return !empty;
    endmethod

    method Action deq if (empty==False);
        deqReq[0] <= True;
    endmethod

    method t first if (empty==False);
        return data[deqP]; 
    endmethod

    method Action clear;
    endmethod
endmodule

/* Exercise 4
Add the clear() method to mkMyCFFifo. It should come after all other interface methods, and it should come before the canonicalize rule. You can build the functional and scheduling testbenches by running
$ make cf
If these compile with no scheduling warning, then the scheduling testbench passed and the FIFO has the expected scheduling behavior. You can run the functional testbench by running
$ ./simCFFunctional
*/

// Confilc Free FIFO
module mkMyCFFifo(Fifo#(n, t)) provisos (Bits#(t,tSz));
    Vector#(n, Reg#(t)) data <- replicateM(mkRegU());
    Reg#(Bit#(TLog#(n))) enqP <- mkReg(0);
    Reg#(Bit#(TLog#(n))) deqP <- mkReg(0);
    Reg#(Bool) empty <- mkReg(True);
    Reg#(Bool) full <- mkReg(False);
    Ehr#(2, Bool) deqReq <- mkEhr(False);
    Ehr#(2, Maybe#(t)) enqReq <- mkEhr(tagged Invalid);
    Ehr#(2, Bool) clearReq <- mkEhr(False);
    Bit#(TLog#(n)) max_index = fromInteger(valueOf(n)-1);

    (* no_implicit_conditions *)
    (* fire_when_enabled *)
    rule canonicalize (True);
        deqReq[1] <= False;
        enqReq[1] <= tagged Invalid;
        clearReq[1] <= False;

        Bit#(TLog#(n)) newdeqP = 0;
        if (deqP == max_index) begin
            newdeqP = 0;
        end else begin
            newdeqP = deqP + 1;
        end

        Bit#(TLog#(n)) newenqP = 0;
        if (enqP == max_index) begin
            newenqP = 0;
        end else begin
            newenqP = enqP + 1;
        end

        case (tuple3(enqReq[1], deqReq[1], clearReq[1])) matches
            {tagged Valid .dat, True, False}: begin
                enqP <= newenqP;
                deqP <= newdeqP;
                data[enqP] <= dat;
            end
            {tagged Valid .dat, False, False}: begin
                enqP <= newenqP;
                data[enqP] <= dat;
                full <= (newenqP == deqP);
                empty <= False;
            end
            {tagged Invalid, True, False}: begin
                deqP <= newdeqP;
                empty <= (newdeqP == enqP);
                full <= False;
            end
            {.*, .*, True}: begin
                enqP <= 0;
                deqP <= 0;
                empty <= True;
                full <= False;
            end
            default: begin end
        endcase      
    endrule

    method Bool notFull;
        return !full;
    endmethod

    method Action enq(t x) if (full==False);
        enqReq[0] <= tagged Valid x; 
    endmethod

    method Bool notEmpty;
        return !empty;
    endmethod

    method Action deq if (empty==False);
        deqReq[0] <= True;
    endmethod

    method t first if (empty==False);
        return data[deqP]; 
    endmethod

    method Action clear;
        clearReq[0] <= True; 
    endmethod
endmodule

