/*
 * Generated by Bluespec Compiler (build 14ff62d)
 * 
 * On Thu Jun 15 20:47:41 PDT 2023
 * 
 */
#include "bluesim_primitives.h"
#include "model_mkTbCFScheduling.h"

#include <cstdlib>
#include <time.h>
#include "bluesim_kernel_api.h"
#include "bs_vcd.h"
#include "bs_reset.h"


/* Constructor */
MODEL_mkTbCFScheduling::MODEL_mkTbCFScheduling()
{
  mkTbCFScheduling_instance = NULL;
}

/* Function for creating a new model */
void * new_MODEL_mkTbCFScheduling()
{
  MODEL_mkTbCFScheduling *model = new MODEL_mkTbCFScheduling();
  return (void *)(model);
}

/* Schedule functions */

static void schedule_posedge_CLK(tSimStateHdl simHdl, void *instance_ptr)
       {
	 MOD_mkTbCFScheduling &INST_top = *((MOD_mkTbCFScheduling *)(instance_ptr));
	 INST_top.DEF_CAN_FIRE_RL_m_deq_fifo_1 = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_deq_fifo_1 = INST_top.DEF_CAN_FIRE_RL_m_deq_fifo_1;
	 INST_top.DEF_CAN_FIRE_RL_m_deq_fifo_2 = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_deq_fifo_2 = INST_top.DEF_CAN_FIRE_RL_m_deq_fifo_2;
	 INST_top.DEF_CAN_FIRE_RL_m_enq_fifo_1 = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_enq_fifo_1 = INST_top.DEF_CAN_FIRE_RL_m_enq_fifo_1;
	 INST_top.DEF_CAN_FIRE_RL_m_enq_fifo_2 = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_enq_fifo_2 = INST_top.DEF_CAN_FIRE_RL_m_enq_fifo_2;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_1_deqReq_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_1_deqReq_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_1_deqReq_canonicalize;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_1_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_1_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_1_canonicalize;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_1_ehr_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_1_ehr_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_1_ehr_canonicalize;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_1_enqReq_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_1_enqReq_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_1_enqReq_canonicalize;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_2_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_2_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_2_canonicalize;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_2_deqReq_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_2_deqReq_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_2_deqReq_canonicalize;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_2_enqReq_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_2_enqReq_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_2_enqReq_canonicalize;
	 INST_top.DEF_CAN_FIRE_RL_m_fifo_2_ehr_canonicalize = (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_m_fifo_2_ehr_canonicalize = INST_top.DEF_CAN_FIRE_RL_m_fifo_2_ehr_canonicalize;
	 if (INST_top.DEF_WILL_FIRE_RL_m_deq_fifo_2)
	   INST_top.RL_m_deq_fifo_2();
	 if (INST_top.DEF_WILL_FIRE_RL_m_enq_fifo_1)
	   INST_top.RL_m_enq_fifo_1();
	 if (INST_top.DEF_WILL_FIRE_RL_m_deq_fifo_1)
	   INST_top.RL_m_deq_fifo_1();
	 if (INST_top.DEF_WILL_FIRE_RL_m_enq_fifo_2)
	   INST_top.RL_m_enq_fifo_2();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_1_canonicalize)
	   INST_top.RL_m_fifo_1_canonicalize();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_1_deqReq_canonicalize)
	   INST_top.RL_m_fifo_1_deqReq_canonicalize();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_1_ehr_canonicalize)
	   INST_top.RL_m_fifo_1_ehr_canonicalize();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_1_enqReq_canonicalize)
	   INST_top.RL_m_fifo_1_enqReq_canonicalize();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_2_canonicalize)
	   INST_top.RL_m_fifo_2_canonicalize();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_2_deqReq_canonicalize)
	   INST_top.RL_m_fifo_2_deqReq_canonicalize();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_2_ehr_canonicalize)
	   INST_top.RL_m_fifo_2_ehr_canonicalize();
	 if (INST_top.DEF_WILL_FIRE_RL_m_fifo_2_enqReq_canonicalize)
	   INST_top.RL_m_fifo_2_enqReq_canonicalize();
	 INST_top.INST_m_fifo_2_ehr_ignored_wires_2.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_ehr_ignored_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_ehr_ignored_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_ehr_wires_2.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_ehr_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_ehr_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_ehr_ignored_wires_2.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_ehr_ignored_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_ehr_ignored_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_ehr_wires_2.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_ehr_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_ehr_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_deqReq_ignored_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_deqReq_ignored_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_deqReq_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_deqReq_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_enqReq_ignored_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_enqReq_ignored_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_enqReq_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_2_enqReq_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_deqReq_ignored_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_deqReq_ignored_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_deqReq_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_deqReq_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_enqReq_ignored_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_enqReq_ignored_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_enqReq_wires_1.clk((tUInt8)1u, (tUInt8)1u);
	 INST_top.INST_m_fifo_1_enqReq_wires_0.clk((tUInt8)1u, (tUInt8)1u);
	 if (do_reset_ticks(simHdl))
	 {
	   INST_top.INST_m_fifo_1_empty.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_1_full.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_1_enqReq_ehrReg.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_1_deqReq_ehrReg.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_2_empty.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_2_full.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_2_enqReq_ehrReg.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_2_deqReq_ehrReg.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_1_ehr_ehrReg.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_m_fifo_2_ehr_ehrReg.rst_tick__clk__1((tUInt8)1u);
	 }
       };

/* Model creation/destruction functions */

void MODEL_mkTbCFScheduling::create_model(tSimStateHdl simHdl, bool master)
{
  sim_hdl = simHdl;
  init_reset_request_counters(sim_hdl);
  mkTbCFScheduling_instance = new MOD_mkTbCFScheduling(sim_hdl, "top", NULL);
  bk_get_or_define_clock(sim_hdl, "CLK");
  if (master)
  {
    bk_alter_clock(sim_hdl, bk_get_clock_by_name(sim_hdl, "CLK"), CLK_LOW, false, 0llu, 5llu, 5llu);
    bk_use_default_reset(sim_hdl);
  }
  bk_set_clock_event_fn(sim_hdl,
			bk_get_clock_by_name(sim_hdl, "CLK"),
			schedule_posedge_CLK,
			NULL,
			(tEdgeDirection)(POSEDGE));
  (mkTbCFScheduling_instance->INST_m_fifo_1_enqReq_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_enqReq_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_enqReq_ignored_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_enqReq_ignored_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_deqReq_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_deqReq_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_deqReq_ignored_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_deqReq_ignored_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_enqReq_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_enqReq_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_enqReq_ignored_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_enqReq_ignored_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_deqReq_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_deqReq_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_deqReq_ignored_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_deqReq_ignored_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_ehr_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_ehr_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_ehr_wires_2.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_ehr_ignored_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_ehr_ignored_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_1_ehr_ignored_wires_2.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_ehr_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_ehr_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_ehr_wires_2.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_ehr_ignored_wires_0.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_ehr_ignored_wires_1.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->INST_m_fifo_2_ehr_ignored_wires_2.set_clk_0)("CLK");
  (mkTbCFScheduling_instance->set_clk_0)("CLK");
}
void MODEL_mkTbCFScheduling::destroy_model()
{
  delete mkTbCFScheduling_instance;
  mkTbCFScheduling_instance = NULL;
}
void MODEL_mkTbCFScheduling::reset_model(bool asserted)
{
  (mkTbCFScheduling_instance->reset_RST_N)(asserted ? (tUInt8)0u : (tUInt8)1u);
}
void * MODEL_mkTbCFScheduling::get_instance()
{
  return mkTbCFScheduling_instance;
}

/* Fill in version numbers */
void MODEL_mkTbCFScheduling::get_version(unsigned int *year,
					 unsigned int *month,
					 char const **annotation,
					 char const **build)
{
  *year = 0u;
  *month = 0u;
  *annotation = NULL;
  *build = "14ff62d";
}

/* Get the model creation time */
time_t MODEL_mkTbCFScheduling::get_creation_time()
{
  
  /* Fri Jun 16 03:47:41 UTC 2023 */
  return 1686887261llu;
}

/* State dumping function */
void MODEL_mkTbCFScheduling::dump_state()
{
  (mkTbCFScheduling_instance->dump_state)(0u);
}

/* VCD dumping functions */
MOD_mkTbCFScheduling & mkTbCFScheduling_backing(tSimStateHdl simHdl)
{
  static MOD_mkTbCFScheduling *instance = NULL;
  if (instance == NULL)
  {
    vcd_set_backing_instance(simHdl, true);
    instance = new MOD_mkTbCFScheduling(simHdl, "top", NULL);
    vcd_set_backing_instance(simHdl, false);
  }
  return *instance;
}
void MODEL_mkTbCFScheduling::dump_VCD_defs()
{
  (mkTbCFScheduling_instance->dump_VCD_defs)(vcd_depth(sim_hdl));
}
void MODEL_mkTbCFScheduling::dump_VCD(tVCDDumpType dt)
{
  (mkTbCFScheduling_instance->dump_VCD)(dt, vcd_depth(sim_hdl), mkTbCFScheduling_backing(sim_hdl));
}
