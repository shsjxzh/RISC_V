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
// Module:  mem
// File:    mem.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 访存阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem(

	input wire	rst,
	
	//来自执行阶段的信息	
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
	input wire[`RegBus]			  wdata_i, //同时承担放store要放的信息的功能
    
    input wire[`OpkindBus]        alu_type_i,
    input wire[`OpcmdBus]         alu_cmd_i,
    input wire[`MemAddrBus]       mem_addr_i,
    
    //来自内存的数据
    input wire[`RegBus]           mem_data_i,
	
	//送到回写阶段的信息
	output reg[`RegAddrBus]       wd_o,     //写入的地址
	output reg                    wreg_o,   //是否写入
	output reg[`RegBus]			  wdata_o,  //写入的数据是什么
    
    //控制
    output wire                    mem_stallreq,
	
    //送到内存的信息
    output reg[`MemAddrBus]       mem_addr_o,
    output reg                    mem_we_o,
    output reg[3:0]               mem_sel_o,
    output reg[`RegBus]           mem_data_o,
    output reg                    mem_ce_o
);

	//assign mem_stallreq = `NoStop;
	//处理暂停
    reg stallreq = 1'b0;
    assign mem_stallreq = stallreq;
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NONRegAddr;
			wreg_o <= `WriteDisable;
		    wdata_o <= `ZeroWord;
            
            mem_addr_o <= `ZeroWord;
            mem_we_o <= `WriteDisable;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
            mem_sel_o <= 4'b0000;
		end else begin
		    wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
            
            mem_addr_o <= `ZeroWord;
            mem_we_o <= `WriteDisable;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
            mem_sel_o <= 4'b1111;
            
            case(alu_type_i)
                `EXE_LOAD_TYPE: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we_o <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    case(alu_cmd_i)
                         `EXE_LB: begin
                            wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                        end
                        `EXE_LH: begin
                            wdata_o <= {{16{mem_data_i[23]}},mem_data_i[23:16],mem_data_i[31:24]};
                        end
                        `EXE_LW: begin
                            wdata_o <= {mem_data_i[7:0], mem_data_i[15:8], mem_data_i[23:16], mem_data_i[31:24]};
                        end
                        `EXE_LBU: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
                        end
                        `EXE_LHU: begin
                            wdata_o <= {{16{1'b0}},mem_data_i[23:16],mem_data_i[31:24]};
                        end
                    endcase
                end
                `EXE_STORE_TYPE: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we_o <= `WriteEnable;
                    mem_ce_o <= `ChipEnable;
                    case(alu_cmd_i)
                        `EXE_SB: begin
                            mem_data_o <= {wdata_i[7:0], wdata_i[7:0], wdata_i[7:0], wdata_i[7:0]};
                            mem_sel_o <= 4'b1000;
                        end
                        `EXE_SH: begin
                            mem_data_o <= {wdata_i[7:0], wdata_i[15:8], wdata_i[7:0], wdata_i[15:8]};
                            mem_sel_o <= 4'b1100;
                        end
                        `EXE_SW: begin
                            mem_data_o <= {wdata_i[7:0], wdata_i[15:8], wdata_i[23:16], wdata_i[31:24]};
                            mem_sel_o <= 4'b1111;
                        end
                    endcase
                end
            endcase
		end    //if
	end      //always
			

endmodule