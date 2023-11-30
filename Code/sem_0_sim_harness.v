/////////////////////////////////////////////////////////////////////////////
//
//
//
/////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /
// \   \   \/    Core:          sem
//  \   \        Module:        sem_0_sim_harness
//  /   /        Filename:      sem_0_sim_harness.v
// /___/   /\    Purpose:       Simulation Harness
// \   \  /  \
//  \___\/\___\
//
/////////////////////////////////////////////////////////////////////////////
//
// (c) Copyright 2010 - 2019 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
//
/////////////////////////////////////////////////////////////////////////////
//
// Module Description:
//
// This module is the Simulation Harness.  Including the controller as part of 
// a larger simulation project is supported. However, SEM controller behaviors 
// can not be observed in simulation. Hardware-based evaluation is required.  
// During simulation, the controller is expected to halt in the initialization 
// state.
//
/////////////////////////////////////////////////////////////////////////////
//
// Port Definition: There are no top level ports.
//
/////////////////////////////////////////////////////////////////////////////
//
// Parameter and Localparam Definition:
//
// Name                          Type   Description
// ============================= ====== ====================================
// THP                           int    Sets the half period for the clock
//                                      generation process.
//
// TSD                           int    Sets the delay in start of output
//                                      checking.
//
// TSC                           int    Number of simulation cycles to run.
//
/////////////////////////////////////////////////////////////////////////////
//
// Module Dependencies:
//
// sem_0_sim_harness
// |
// \- sem_0_sem_example
//
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

/////////////////////////////////////////////////////////////////////////////
// Module
/////////////////////////////////////////////////////////////////////////////

module sem_0_sim_harness;

  ///////////////////////////////////////////////////////////////////////////
  // Define local constants.
  ///////////////////////////////////////////////////////////////////////////

  localparam TSD = 2000000;
  localparam TSC = 2047;
  localparam THP = 62500;

  ///////////////////////////////////////////////////////////////////////////
  // Declare signals.
  ///////////////////////////////////////////////////////////////////////////

  reg  [31:0] simulation_cycles = 32'h00000000;
  reg         check_outputs = 1'b0;
  reg         tb_error = 1'b0;
  reg         clk = 1'b0;
  wire        status_heartbeat;
  wire        status_initialization;
  wire        status_observation;
  wire        status_correction;
  wire        status_classification;
  wire        status_injection;
  wire        status_essential;
  wire        status_uncorrectable;
  wire        monitor_tx;
  wire        monitor_rx;
  wire        external_c;
  wire        external_d;
  wire        external_s_n;
  wire        external_q;


  ///////////////////////////////////////////////////////////////////////////
  // Instantiate the example design.
  ///////////////////////////////////////////////////////////////////////////

  sem_0_sem_example example_sim_harness (
    .clk(clk),
    .status_heartbeat(status_heartbeat),
    .status_initialization(status_initialization),
    .status_observation(status_observation),
    .status_correction(status_correction),
    .status_classification(status_classification),
    .status_injection(status_injection),
    .status_essential(status_essential),
    .status_uncorrectable(status_uncorrectable),
    .external_c(external_c),
    .external_d(external_d),
    .external_s_n(external_s_n),
    .external_q(external_q),
    .monitor_tx(monitor_tx),
    .monitor_rx(monitor_rx)
  );

  ///////////////////////////////////////////////////////////////////////////
  // Clock generation process.
  ///////////////////////////////////////////////////////////////////////////

  always
  begin
    #THP;
    clk <= 1'b0;
    #THP;
    clk <= 1'b1;
  end

  ///////////////////////////////////////////////////////////////////////////
  // Simulation cycle count process.
  ///////////////////////////////////////////////////////////////////////////

  always @(posedge clk)
  begin
    if (simulation_cycles == 32'h00000000)
    begin
      $display("NOTE: Simulation starting...");
    end
    if (simulation_cycles == TSC)
    begin
      $display("NOTE: Simulation ending...");
      if (tb_error == 1'b1)
        $display("INFO: Test Completed with Errors");
      else
        $display("INFO: Test Completed Successfully");
      $stop;
    end
    simulation_cycles <= simulation_cycles + 32'h00000001;
    $display("INFO: Simulation advancing...");
  end

  ///////////////////////////////////////////////////////////////////////////
  // Input signal assignments.
  ///////////////////////////////////////////////////////////////////////////

  assign monitor_rx = 1'b1;
  assign external_q = 1'b1;

  ///////////////////////////////////////////////////////////////////////////
  // Output signal monitoring.
  ///////////////////////////////////////////////////////////////////////////

  initial
  begin
    $display("Functional and timing simulation of designs that include the SEM Controller is supported. However, it is not possible to observe the SEM Controller behaviors in simulation. Hardware-based evaluation is required.");
    check_outputs <= 1'b0;
    #TSD;
    check_outputs <= 1'b1;
  end

  always @*
  begin
    if (check_outputs && (status_heartbeat !== 1'b0) && (status_heartbeat !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_heartbeat value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (status_initialization !== 1'b0) && (status_initialization !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_initialization value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (status_observation !== 1'b0) && (status_observation !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_observation value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (status_correction !== 1'b0) && (status_correction !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_correction value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (status_classification !== 1'b0) && (status_classification !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_classification value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (status_injection !== 1'b0) && (status_injection !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_injection value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (status_essential !== 1'b0) && (status_essential !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_essential value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (status_uncorrectable !== 1'b0) && (status_uncorrectable !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected status_uncorrectable value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (monitor_tx !== 1'b0) && (monitor_tx !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected monitor_tx value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (external_c !== 1'b0) && (external_c !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected external_c value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (external_d !== 1'b0) && (external_d !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected external_d value.");
         tb_error <= 1'b1;
      end
  end

  always @*
  begin
    if (check_outputs && (external_s_n !== 1'b0) && (external_s_n !== 1'b1))
      begin
         $display("ERROR - TEST FAILED: Unexpected external_s_n value.");
         tb_error <= 1'b1;
      end
 end

  ///////////////////////////////////////////////////////////////////////////
  //
  ///////////////////////////////////////////////////////////////////////////

endmodule

/////////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////////
