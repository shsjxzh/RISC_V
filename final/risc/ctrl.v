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
// Description: ����ģ�飬������ˮ�ߵ�ˢ�¡���ͣ��
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ctrl(

	input wire					 rst,
    
    //��һ���޸ġ���ʱ����������Ҳ����Ҫ���ĳ�����ͣ��
    input wire                   stallreq_if,
    //Ϊ����������
    input wire                   stallreq_if2,
	input wire                   stallreq_id,
	input wire                   stallreq_ex,
    input wire                   stallreq_mem,
    //input wire                   stallreq__wb,
    
    /*
    stall[0]��ʾȡָ��ַPC�Ƿ񱣳ֲ��䣬1����
    stall[1]��ʾif�׶��Ƿ���ͣ��1��ͣ
    stall[2]��ʾid�׶��Ƿ���ͣ
    stall[3]��ʾex�׶��Ƿ���ͣ
    stall[4]��ʾmem�׶��Ƿ�Ҫ��ͣ
    stall[5]��ʾwb�׶��Ƿ�Ҫ��ͣ
    
    //stall[5]��������˼��һ��׼������
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
        //��һ��if��ʾ�������if��ͣ������Ҫ��ͣһ������
		end else if(stallreq_if == `Stop || stallreq_id == `Stop) begin
			stall <= 6'b000111;
        end else if(stallreq_if2 == `Stop) begin
			stall <= 6'b000011;	
		end else begin
			stall <= 6'b000000;
		end    //if
	end      //always
			

endmodule