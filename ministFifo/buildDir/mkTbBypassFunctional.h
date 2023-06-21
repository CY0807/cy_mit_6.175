/*
 * Generated by Bluespec Compiler (build 14ff62d)
 * 
 * On Sat Jun 10 08:58:49 PDT 2023
 * 
 */

/* Generation options: keep-fires */
#ifndef __mkTbBypassFunctional_h__
#define __mkTbBypassFunctional_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkTbBypassFunctional module */
class MOD_mkTbBypassFunctional : public Module {
 
 /* Clock handles */
 private:
  tClock __clk_handle_0;
 
 /* Clock gate handles */
 public:
  tUInt8 *clk_gate[0];
 
 /* Instantiation parameters */
 public:
 
 /* Module state */
 public:
  MOD_Reg<tUInt8> INST_fifo_data;
  MOD_Reg<tUInt8> INST_fifo_empty_ehrReg;
  MOD_Wire<tUInt8> INST_fifo_empty_ignored_wires_0;
  MOD_Wire<tUInt8> INST_fifo_empty_ignored_wires_1;
  MOD_Reg<tUInt8> INST_fifo_empty_virtual_reg_0;
  MOD_Reg<tUInt8> INST_fifo_empty_virtual_reg_1;
  MOD_Wire<tUInt8> INST_fifo_empty_wires_0;
  MOD_Wire<tUInt8> INST_fifo_empty_wires_1;
  MOD_Reg<tUInt8> INST_fifo_full_ehrReg;
  MOD_Wire<tUInt8> INST_fifo_full_ignored_wires_0;
  MOD_Wire<tUInt8> INST_fifo_full_ignored_wires_1;
  MOD_Reg<tUInt8> INST_fifo_full_virtual_reg_0;
  MOD_Reg<tUInt8> INST_fifo_full_virtual_reg_1;
  MOD_Wire<tUInt8> INST_fifo_full_wires_0;
  MOD_Wire<tUInt8> INST_fifo_full_wires_1;
  MOD_Reg<tUInt32> INST_m_cycle;
  MOD_Reg<tUInt32> INST_m_input_count;
  MOD_Reg<tUInt32> INST_m_output_count;
  MOD_Wire<tUInt8> INST_m_randomA_ignore;
  MOD_Reg<tUInt8> INST_m_randomA_initialized;
  MOD_Wire<tUInt8> INST_m_randomA_zaz;
  MOD_Wire<tUInt8> INST_m_randomB_ignore;
  MOD_Reg<tUInt8> INST_m_randomB_initialized;
  MOD_Wire<tUInt8> INST_m_randomB_zaz;
  MOD_Wire<tUInt8> INST_m_randomC_ignore;
  MOD_Reg<tUInt8> INST_m_randomC_initialized;
  MOD_Wire<tUInt8> INST_m_randomC_zaz;
  MOD_Wire<tUInt8> INST_m_randomData_ignore;
  MOD_Reg<tUInt8> INST_m_randomData_initialized;
  MOD_Wire<tUInt8> INST_m_randomData_zaz;
  MOD_CReg<tUInt32> INST_m_ref_fifo_rv;
 
 /* Constructor */
 public:
  MOD_mkTbBypassFunctional(tSimStateHdl simHdl, char const *name, Module *parent);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_WILL_FIRE_RL_m_cycle_inc;
  tUInt8 DEF_CAN_FIRE_RL_m_cycle_inc;
  tUInt8 DEF_WILL_FIRE_RL_m_stop_tb;
  tUInt8 DEF_CAN_FIRE_RL_m_stop_tb;
  tUInt8 DEF_WILL_FIRE_RL_m_check_fifos_first;
  tUInt8 DEF_CAN_FIRE_RL_m_check_fifos_first;
  tUInt8 DEF_WILL_FIRE_RL_m_feed_inputs;
  tUInt8 DEF_WILL_FIRE_RL_m_check_fifos_not_empty;
  tUInt8 DEF_CAN_FIRE_RL_m_check_fifos_not_empty;
  tUInt8 DEF_WILL_FIRE_RL_m_check_fifos_not_full;
  tUInt8 DEF_CAN_FIRE_RL_m_check_fifos_not_full;
  tUInt8 DEF_WILL_FIRE_RL_m_check_outputs;
  tUInt8 DEF_CAN_FIRE_RL_m_check_outputs;
  tUInt8 DEF_CAN_FIRE_RL_m_feed_inputs;
  tUInt8 DEF_WILL_FIRE_RL_m_init;
  tUInt8 DEF_CAN_FIRE_RL_m_init;
  tUInt8 DEF_WILL_FIRE_RL_m_randomData_every_1;
  tUInt8 DEF_CAN_FIRE_RL_m_randomData_every_1;
  tUInt8 DEF_WILL_FIRE_RL_m_randomData_every;
  tUInt8 DEF_CAN_FIRE_RL_m_randomData_every;
  tUInt8 DEF_WILL_FIRE_RL_m_randomC_every_1;
  tUInt8 DEF_CAN_FIRE_RL_m_randomC_every_1;
  tUInt8 DEF_WILL_FIRE_RL_m_randomC_every;
  tUInt8 DEF_CAN_FIRE_RL_m_randomC_every;
  tUInt8 DEF_WILL_FIRE_RL_m_randomB_every_1;
  tUInt8 DEF_CAN_FIRE_RL_m_randomB_every_1;
  tUInt8 DEF_WILL_FIRE_RL_m_randomB_every;
  tUInt8 DEF_CAN_FIRE_RL_m_randomB_every;
  tUInt8 DEF_WILL_FIRE_RL_m_randomA_every_1;
  tUInt8 DEF_CAN_FIRE_RL_m_randomA_every_1;
  tUInt8 DEF_WILL_FIRE_RL_m_randomA_every;
  tUInt8 DEF_CAN_FIRE_RL_m_randomA_every;
  tUInt8 DEF_WILL_FIRE_RL_fifo_full_canonicalize;
  tUInt8 DEF_CAN_FIRE_RL_fifo_full_canonicalize;
  tUInt8 DEF_WILL_FIRE_RL_fifo_empty_canonicalize;
  tUInt8 DEF_CAN_FIRE_RL_fifo_empty_canonicalize;
  tUInt8 DEF_fifo_empty_virtual_reg_1_read__7_OR_IF_fifo_em_ETC___d71;
  tUInt8 DEF_fifo_empty_virtual_reg_1_read____d67;
  tUInt8 DEF_fifo_full_virtual_reg_1_read__6_OR_fifo_full_v_ETC___d50;
  tUInt8 DEF_fifo_full_ehrReg__h1671;
  tUInt8 DEF_fifo_full_virtual_reg_1_read____d46;
  tUInt8 DEF_fifo_full_virtual_reg_0_read____d47;
  tUInt32 DEF_x__h5741;
  tUInt32 DEF_x__h5889;
  tUInt32 DEF_m_ref_fifo_rv_port1__read____d65;
  tUInt8 DEF_x_wget__h2669;
  tUInt8 DEF_x_wget__h2279;
  tUInt8 DEF_fifo_empty_wires_0_whas____d3;
  tUInt8 DEF_fifo_empty_wires_0_wget____d4;
  tUInt8 DEF_fifo_empty_ehrReg__h5359;
  tUInt8 DEF_m_ref_fifo_rv_port1__read__5_BIT_8___d66;
  tUInt8 DEF_v__h2417;
  tUInt8 DEF_v__h2806;
  tUInt8 DEF_m_input_count_8_EQ_1024___d100;
  tUInt8 DEF_IF_m_randomB_zaz_whas__6_THEN_m_randomB_zaz_wg_ETC___d64;
  tUInt8 DEF_IF_m_randomA_zaz_whas__9_THEN_m_randomA_zaz_wg_ETC___d45;
  tUInt8 DEF_NOT_m_ref_fifo_rv_port0__read__1_BIT_8_2___d53;
 
 /* Local definitions */
 private:
  tUInt8 DEF_IF_fifo_empty_wires_0_whas_THEN_fifo_empty_wir_ETC___d6;
  tUInt32 DEF_v__h3503;
  tUInt32 DEF_v__h3113;
  tUInt32 DEF_v__h2726;
  tUInt32 DEF_v__h2336;
  tUInt32 DEF_x__h5479;
  tUInt8 DEF_x_wget__h3446;
  tUInt8 DEF_y__h5675;
  tUInt8 DEF_x_first__h1978;
  tUInt8 DEF_v__h3583;
  tUInt8 DEF_IF_fifo_full_wires_0_whas__0_THEN_fifo_full_wi_ETC___d13;
 
 /* Rules */
 public:
  void RL_fifo_empty_canonicalize();
  void RL_fifo_full_canonicalize();
  void RL_m_randomA_every();
  void RL_m_randomA_every_1();
  void RL_m_randomB_every();
  void RL_m_randomB_every_1();
  void RL_m_randomC_every();
  void RL_m_randomC_every_1();
  void RL_m_randomData_every();
  void RL_m_randomData_every_1();
  void RL_m_init();
  void RL_m_feed_inputs();
  void RL_m_check_outputs();
  void RL_m_check_fifos_not_full();
  void RL_m_check_fifos_not_empty();
  void RL_m_check_fifos_first();
  void RL_m_stop_tb();
  void RL_m_cycle_inc();
 
 /* Methods */
 public:
 
 /* Reset routines */
 public:
  void reset_RST_N(tUInt8 ARG_rst_in);
 
 /* Static handles to reset routines */
 public:
 
 /* Pointers to reset fns in parent module for asserting output resets */
 private:
 
 /* Functions for the parent module to register its reset fns */
 public:
 
 /* Functions to set the elaborated clock id */
 public:
  void set_clk_0(char const *s);
 
 /* State dumping routine */
 public:
  void dump_state(unsigned int indent);
 
 /* VCD dumping routines */
 public:
  unsigned int dump_VCD_defs(unsigned int levels);
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkTbBypassFunctional &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkTbBypassFunctional &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkTbBypassFunctional &backing);
};

#endif /* ifndef __mkTbBypassFunctional_h__ */