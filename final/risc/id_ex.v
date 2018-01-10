//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  id_ex
// File:    id_ex.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: ID/EX阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module id_ex(

	input wire	clk,
	input wire	rst,

	
	//从译码阶段传递的信息
    input wire[`OpkindBus]        id_alu_type,
    input wire[`OpcmdBus]         id_alu_cmd,
    
	input wire[`RegBus]           id_op_data1,
	input wire[`RegBus]           id_op_data2,
	input wire[`RegAddrBus]       id_wd,
	input wire                    id_wreg,

    //来自控制
    input wire[5:0]               stall,
    //内存专用
    input wire[`RegBus]           store_data_i,
	
	//传递到执行阶段的信息
    
    output reg[`OpkindBus]        ex_alu_type,
    output reg[`OpcmdBus]         ex_alu_cmd,
	output reg[`RegBus]           ex_op_data1,
	output reg[`RegBus]           ex_op_data2,
	output reg[`RegAddrBus]       ex_wd,
	output reg                    ex_wreg,
    output reg[`RegBus]           store_data_o
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_alu_type <= `EXE_NON_OP;
            ex_alu_cmd <= `EXE_NON_TYPE;
            
            ex_op_data1 <= `ZeroWord;
			ex_op_data2 <= `ZeroWord;
			ex_wd <= `NONRegAddr;
			ex_wreg <= `WriteDisable;
            
            store_data_o <= `ZeroWord;
            
		end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            ex_alu_type <= `EXE_NON_OP;
            ex_alu_cmd <= `EXE_NON_TYPE;
            
            ex_op_data1 <= `ZeroWord;
			ex_op_data2 <= `ZeroWord;
			ex_wd <= `NONRegAddr;
			ex_wreg <= `WriteDisable;
            
            store_data_o <= `ZeroWord;
        end
        else if (stall[2] == `NoStop) begin
			ex_alu_type <= id_alu_type;
            ex_alu_cmd <= id_alu_cmd;

			ex_op_data1 <= id_op_data1;
			ex_op_data2 <= id_op_data2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;	
            
            store_data_o <= store_data_i;
		end
	end
	
endmodule