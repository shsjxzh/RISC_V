`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/17 23:27:12
// Design Name: 
// Module Name: Pc_reg
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

module pc_reg(
    input wire clk,
    input wire rst,
    //input wire[5:0] stall,
    
    input wire          branch_flag_i,
    input wire[`RegBus] branch_target_address_i,
    input wire[5:0]     stall,  //��ͣ��Ϣ
    
    output reg[`InstAddrBus] pc,
    output reg ce
    //output wire stallreq  //����ӿ��Ժ����ڷ��ʽ���ʱ��
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable; //��λʱ�����źŸ�ָ��洢����ֹ�䱻����
        end
        else begin
            ce <=  `ChipEnable;
        end
     end
     
     //��һ�������ػᷢ��ʲô���飿
     always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= `ZeroWord;
        end
        else begin
            //if (stall[0] == `NoStop) begin
            if (branch_flag_i == `Branch) begin
                pc <= branch_target_address_i;
            end else if (stall[0] == `NoStop) begin
                pc <= pc + 4'h4;    //��һ��ָ�32λ֮��
            end
        end
     end
endmodule
