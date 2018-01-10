`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/18 13:43:34
// Design Name: 
// Module Name: regfile
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

module regfile(
    input wire clk,
    input wire rst,
    
    //д�Ķ˿�
    input wire we,  //ʹ����д���ź�
    input wire[`RegAddrBus] waddr,  //д��ļĴ�����ַ
    input wire[`RegBus] wdata,      //д������ݡ�����ĸ�ʽ��ͬ
    
    //���˿�1
    input wire re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus] rdata1,

    //���˿�2
    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
    );
    
    //����32��32λ�Ĵ���
    reg[`RegBus] regs[0:`RegNum-1];
    
    //д����
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin    //��Ĵ����Ƿ���Ҫ���ⱻ�޸���Ҫ��Ӳ��ʵ������д����ǿ³����
                regs[waddr] <= wdata;   //Ӧ�ñ�֤��ַ�Ĵ��ݺ����ݵĴ�����ѭС����
            end
        end
    end
    
    //���˿�1����
    //��������ƽ�����źſ��ܶ��˼���
    always @ (*) begin
        if ((rst == `RstEnable) || (raddr1 == `RegNumLog2'h0)) begin
            rdata1 <= `ZeroWord;
        end
        else if ((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
            rdata1 <= wdata;
        end
        else if (re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end
        else begin
            rdata1 <= `ZeroWord;
        end
    end

    //���˿�2����
    always @ (*) begin
        if ((rst == `RstEnable) || (raddr2 == `RegNumLog2'h0)) begin
            rdata2 <= `ZeroWord;
        end
        else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
            rdata2 <= wdata;
        end
        else if (re2 == `ReadEnable) begin
            rdata2 <= regs[raddr2];
        end
        else begin
            rdata2 <= `ZeroWord;
        end
    end
endmodule
