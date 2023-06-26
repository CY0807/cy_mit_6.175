// OneCycle.bsv
//
// This is a one cycle implementation of the RISC-V processor.

import Types::*;
import ProcTypes::*;
import MemTypes::*;
import RFile::*;
import IMemory::*;
import DMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import Fifo::*;
import Ehr::*;

(* synthesize *)
module mkProc(Proc);
    Reg#(Addr) pc <- mkRegU;
    RFile      rf <- mkRFile;
    IMemory  iMem <- mkIMemory;
    DMemory  dMem <- mkDMemory;
    CsrFile  csrf <- mkCsrFile;

    Bool memReady = iMem.init.done() && dMem.init.done();

    rule doProc(csrf.started);
        Data inst = iMem.req(pc);

        // decode
        // TODO: fill the second param.
        DecodedInst dInst = decode(inst, csrf.getMstatus()[2:1] == 2'b00);

        // trace - print the instruction
        $display("pc: %h inst: (%h) expanded: ", pc, inst, showInst(inst));
		$display("decoded: ", fshow(dInst));

        // read general purpose register values 
        Data rVal1 = rf.rd1(fromMaybe(?, dInst.src1));
        Data rVal2 = rf.rd2(fromMaybe(?, dInst.src2));

        // read CSR values (for CSRR & CSRRW inst)
        Data csrVal = csrf.rd(fromMaybe(?, dInst.csr));
		$display("regread: rs1 = %h, rs2 = %h, csr = %h", rVal1, rVal2, csrVal);

        // execute
        ExecInst eInst = exec(dInst, rVal1, rVal2, pc, ?, csrVal);  
		// The fifth argument above is the predicted pc, to detect if it was mispredicted. 
		// Since there is no branch prediction, this field is sent with a random value

        // memory
        if(eInst.iType == Ld) begin
            eInst.data <- dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
        end else if(eInst.iType == St) begin
            let d <- dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
        end
		$display("executed: ", fshow(eInst));

		// commit
        // check exception at commit time.
        if(eInst.iType == NoPermission) begin
            $fwrite(stderr, "ERROR: Executing NoPermission instruction. Exiting\n");
            $finish; // exit
        end
		else if(eInst.iType == Unsupported) begin
			$display("Unsupported instruction. Trap");
			// TODO: unsupported instruction exception
            let curState = csrf.getMstatus();
            let newState = (curState << 3);
            newState[2:1] = 2'b11; // machine mode
            newState[0] = 0;  // disable interrupt in new mode
            csrf.startExcep(pc, excepUnsupport, newState);
            pc <= csrf.getMtvec();
		end
		else if(eInst.iType == ECall) begin
			$display("System call. Trap");
			// TODO: system call exception
            let curState = csrf.getMstatus();
            let newState = (curState << 3);
            newState[2:1] = 2'b11; // machine mode
            newState[0] = 0;  // disable interrupt in new mode
            csrf.startExcep(pc, excepUserECall, newState);
            pc <= csrf.getMtvec();
		end
		else if(eInst.iType == ERet) begin
			$display("ERET");
			// TODO: return from exception
            let curState = csrf.getMstatus();
            let newState = (curState >> 3);
            csrf.eret(newState);
            pc <= csrf.getMepc();
		end
		else begin
			// normal inst
			// write back to reg file
			if(isValid(eInst.dst)) begin
				rf.wr(fromMaybe(?, eInst.dst), eInst.data);
			end
			// update the pc depending on whether the branch is taken or not
			pc <= eInst.brTaken ? eInst.addr : pc + 4;
			// CSRRW write CSR (including sending data to host & stats, modifying states)
			csrf.wr(eInst.iType == Csrrw ? eInst.csr : Invalid, eInst.csrData);
		end
    endrule

    method ActionValue#(CpuToHostData) cpuToHost;
        let ret <- csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if ( !csrf.started && memReady );
        csrf.start(0); // only 1 core, id = 0
        pc <= startpc;
    endmethod

    interface iMemInit = iMem.init;
    interface dMemInit = dMem.init;
endmodule

