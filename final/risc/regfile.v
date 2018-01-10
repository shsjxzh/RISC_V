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
    
    //写的端口
    input wire we,  //使其能写的信号
    input wire[`RegAddrBus] waddr,  //写入的寄存器地址
    input wire[`RegBus] wdata,      //写入的数据。后面的格式相同
    
    //读端口1
    input wire re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus] rdata1,

    //读端口2
    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
    );
    
    //定义32个32位寄存器
    reg[`RegBus] regs[0:`RegNum-1];
    
    //写操作
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin    //零寄存器是否需要避免被修改需要在硬件实现吗？先写以增强鲁棒性
                regs[waddr] <= wdata;   //应该保证地址的传递和数据的传递遵循小端序
            end
        end
    end
    
    //读端口1操作
    //这边这个电平敏感信号可能多了几个
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

    //读端口2操作
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
