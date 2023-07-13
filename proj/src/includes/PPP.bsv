import ProcTypes::*;
import MemTypes::*;
import Types::*;
import CacheTypes::*;
import MessageFifo::*;
import Vector::*;
import FShow::*;

typedef enum {
    SendResp2Child,
    WaitDownGradComplete,
    WaitMemData
} ChidReqHandleState deriving(Bits, Eq, FShow);


module mkPPP(MessageGet c2m, MessagePut m2c, WideMem mem, Empty ifc);

    Vector#(CoreNum, Vector#(CacheRows, Reg#(MSI))) childState <- replicateM(replicateM(mkReg(I)));
    Vector#(CoreNum, Vector#(CacheRows, Reg#(CacheTag))) childTag <- replicateM(replicateM(mkRegU));
    Vector#(CoreNum, Vector#(CacheRows, Bool)) wait_for_downgrade <- replicateM(replicateM(mkReg(0)));

    Reg#(Bool) missReg <- mkReg(False);
    Reg#(ChidReqHandleState) stateReg <- mkReg(SendResp2Child);

    function Bool isCompatible(MSI cur, MSI next)
        return (cur == I || next == I || (cur == S && next == S));
    endfunction

    rule doSendResp2Child if (stateReg == SendResp2Child && !c2m.hasResp);
        let req = c2m.first;
        let req_addr
        let index = 
    endrule


endmodule