`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 13:16:28
// Design Name: 
// Module Name: if_id
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module if_id(
    input wire clk,
    input wire rst,
    
    input wire[`InstAddrBus] if_pc, //指令地址
    input wire[`InstBus]     if_inst,   //InstBus表示指令的宽度
    
    //来自控制
    input wire[5:0]          stall,
    
    output reg[`InstAddrBus] id_pc, //译码阶段的指令对应的地址
    output reg[`InstBus]     id_inst   //译码阶段所需读取的指令
    //output wire              if_stallreq
    
    );
    //reg stallreq = 1'b0;
    //assign if_stallreq = stallreq;
    
    always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;	
	  end else if(stall[1] == `NoStop) begin
		  id_pc <= if_pc;
		  id_inst <= if_inst;
		end
	end
endmodule
