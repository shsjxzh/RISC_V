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
// Module:  ctrl
// File:    ctrl.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 控制模块，控制流水线的刷新、暂停等
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ctrl(

	input wire					 rst,
    
    //做一个修改。这时候其他程序也可以要求别的程序暂停。
    input wire                   stallreq_if,
    //为多驱动测试
    input wire                   stallreq_if2,
	input wire                   stallreq_id,
	input wire                   stallreq_ex,
    input wire                   stallreq_mem,
    //input wire                   stallreq__wb,
    
    /*
    stall[0]表示取指地址PC是否保持不变，1不变
    stall[1]表示if阶段是否暂停，1暂停
    stall[2]表示id阶段是否暂停
    stall[3]表示ex阶段是否暂停
    stall[4]表示mem阶段是否要暂停
    stall[5]表示wb阶段是否要暂停
    
    //stall[5]有意义吗？思考一下准备砍掉
    */
	output reg[5:0]              stall       
	
);
    /*reg _mem, _ex, _id, _if;
    always @ (*) begin
        if(rst == `RstEnable) begin
            _mem <= 1'b0;
            _ex <= 1'b0;
            _id<= 1'b0;
            _if<= 1'b0;
        end
        else begin
            _mem <= stallreq_mem;
            _ex <=stallreq_ex;
            _id<= stallreq_id;
            _if<= stallreq_if;
        end
    end
    
    always @ (*) begin
            if(rst == `RstEnable) begin
                stall <= 6'b000000;
            end else if(_mem == `Stop) begin
                stall <= 6'b011111;
            end else if(_ex == `Stop) begin
                stall <= 6'b001111;    
            end else if(_id == `Stop) begin
                stall <= 6'b000111;
            end else if(_if == `Stop) begin
                stall <= 6'b000011;    
            end else begin
                stall <= 6'b000000;
            end    //if
    end*/
	always @ (*) begin
		if(rst == `RstEnable) begin
			stall <= 6'b000000;
        end else if(stallreq_mem == `Stop) begin
            stall <= 6'b011111;
        end else if(stallreq_ex == `Stop) begin
			stall <= 6'b001111;	            
        //第一个if表示的是真的if暂停，但是要多停一个周期
		end else if(stallreq_if == `Stop || stallreq_id == `Stop) begin
			stall <= 6'b000111;
        end else if(stallreq_if2 == `Stop) begin
			stall <= 6'b000011;	
		end else begin
			stall <= 6'b000000;
		end    //if
	end      //always
			

endmodule