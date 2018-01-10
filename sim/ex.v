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
// Module:  ex
// File:    ex.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 执行阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex(

	input wire	rst,
	
    input wire[`OpkindBus]        alu_type_i,
    input wire[`OpcmdBus]         alu_cmd_i,
    
	input wire[`RegBus]           op_data1_i,
	input wire[`RegBus]           op_data2_i,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
    
    //为store专门留存的数据
    input wire[`RegBus]           store_data_i, 
	
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
	output reg[`RegBus]			  wdata_o,
    
    //内存需要的信息
    output reg[`MemAddrBus]       mem_addr_o,
    output reg[`OpkindBus]        alu_type_o,
    output reg[`OpcmdBus]         alu_cmd_o,
    
    //暂停信息
    output wire                    ex_stallreq
	
);

	reg[`RegBus] logicout;
    reg[`RegBus] shiftres;
    reg[`RegBus] arithmeticres;
    reg[`RegBus] jump_address;
    
    wire[`RegBus] op_data2_i_mux;
    //wire[`RegBus] op_data2_i_mux2;
    wire[`RegBus] result_sum;
    //wire[`RegBus] op_data1_i_not;
    //wire op_data1_eq_op_data2;
	wire op_data1_lt_op_data2; 
    
    //处理暂停
    reg stallreq = 1'b0;
    assign ex_stallreq = stallreq;
    
    always @(*) begin
       	if(rst == `RstEnable) begin
           alu_cmd_o <= `EXE_NON_OP;
           alu_type_o <= `EXE_NON_TYPE;
        end 
        else begin
            alu_type_o <= alu_type_i;
            alu_cmd_o <= alu_cmd_i;
        end
    end
    
    assign op_data2_i_mux = ((alu_cmd_i == `EXE_SUB) || (alu_cmd_i == `EXE_SLT) ) 
                        ? (~op_data2_i)+1 : op_data2_i;
    assign result_sum = op_data1_i + op_data2_i_mux;
    assign op_data1_lt_op_data2 = ((alu_cmd_i == `EXE_SLT)) ?
                                ((op_data1_i[31] && !op_data2_i[31]) || 
                                  (!op_data1_i[31] && !op_data2_i[31] && result_sum[31])||
                                  (op_data1_i[31] && op_data2_i[31] && result_sum[31]))
                               :    (op_data1_i < op_data2_i);
    //逻辑运算
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end 
        else if (alu_type_i == `EXE_LOGIC_TYPE) begin
            case (alu_cmd_i)
                `EXE_OR: begin
                    logicout <= op_data1_i | op_data2_i;
                end
                `EXE_AND: begin
                    logicout <= op_data1_i & op_data2_i;
                end
                `EXE_XOR: begin
                    logicout <= op_data1_i ^ op_data2_i;
                end
                /*`EXE_LUI: begin
                    logicout <= op_data1_i;
                end*/
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase  //func3
		end    //if
	end      //always
   

    //跳转以及lui
    always @ (*) begin
        if(rst == `RstEnable) begin
			jump_address <= `ZeroWord;
		end
        else begin
            case(alu_type_i)
                `EXE_JUMP_TYPE: begin
                    jump_address <= op_data2_i;
                end
                default:    begin
                    jump_address <= `ZeroWord;
                end
            endcase
        end
        /* else if (alu_type_i == `EXE_JUMP_TYPE) begin
            jump_address <= op_data2_i;
        end */
    end
    
    
   
    
    //移位运算
    always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else if (alu_type_i == `EXE_SHIFT_TYPE) begin
            case (alu_cmd_i)
                `EXE_SLL:			begin
                    shiftres <= op_data1_i << op_data2_i[4:0];
                end
                `EXE_SRL:		begin
                    shiftres <= op_data1_i >> op_data2_i[4:0];
                end
                `EXE_SRA:		begin
                    shiftres <= ({32{op_data1_i[31]}} << (6'd32-{1'b0, op_data2_i[4:0]})) 
                                                | op_data1_i >> op_data2_i[4:0];
                end
                default:				begin
                    shiftres <= `ZeroWord;
                end
            endcase
		end    //if
	end
    
    //算术运算                           
	always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
        end else if (alu_type_i == `EXE_ARITHMETIC_TYPE) begin
            case (alu_cmd_i)
                `EXE_SLT, `EXE_SLTU:		begin
                    arithmeticres <= op_data1_lt_op_data2 ;
                end
                `EXE_ADD, `EXE_SUB:		begin
                    arithmeticres <= result_sum; 
                end
                default:				begin
                    arithmeticres <= `ZeroWord;
                end
            endcase
        end
   end
   
   //计算内存地址
   always @ (*) begin
		if(rst == `RstEnable) begin
			mem_addr_o <= `ZeroWord;
	   end
	   else begin
           case(alu_type_i)
              `EXE_LOAD_TYPE,`EXE_STORE_TYPE: begin
                   mem_addr_o <= op_data1_i + store_data_i;
               end
               default:    begin
                   mem_addr_o <= `ZeroWord;
               end
           endcase
       end
        /*end else if (alu_type_i == `EXE_LOAD_TYPE || alu_type_i == `EXE_STORE_TYPE) begin
            mem_addr_o <= op_data1_i + store_data_i;
            //wdata_o <= ;
        end*/
   end

 always @ (*) begin
	 wd_o <= wd_i;	 	 	
	 wreg_o <= wreg_i;
	 case ( alu_type_i ) 
	 	`EXE_LOGIC_TYPE:		begin
	 		wdata_o <= logicout;
	 	end
	 	`EXE_SHIFT_TYPE:		begin
	 		wdata_o <= shiftres;
	 	end
        `EXE_ARITHMETIC_TYPE:   begin
            wdata_o <= arithmeticres;
        end
        `EXE_JUMP_TYPE:         begin
            wdata_o <= jump_address;
        end
        `EXE_STORE_TYPE:        begin
            wdata_o <= op_data2_i;
        end
	 	default:			    begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end		

endmodule
