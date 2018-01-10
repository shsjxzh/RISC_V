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
// Module:  openmips
// File:    openmips.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: OpenMIPS�������Ķ����ļ�
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module risc(

	input wire clk,
	input wire rst,
 
	input wire[`RegBus]           rom_data_i,
	output wire[`RegBus]          rom_addr_o,
	output wire                   rom_ce_o,
    
    //�������ݴ洢��data_ram
	input wire[`RegBus]            ram_data_i,
	output wire[`RegBus]           ram_addr_o,
	output wire[`RegBus]           ram_data_o,
	output wire                    ram_we_o,
	output wire[3:0]               ram_sel_o,
	output wire                    ram_ce_o
	
);

	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	
	//��������׶�IDģ��������ID/EXģ�������
	wire[`OpkindBus]      id_alu_type;        //ָ���opcode
    wire[`OpcmdBus]       id_alu_cmd;        //ָ��funct3
       
	wire[`RegBus]         id_op_data1_o;
	wire[`RegBus]         id_op_data2_o;
	wire                  id_wreg_o;
	wire[`RegAddrBus]     id_wd_o;
    wire[`RegBus]         id_store_data_o;
	
	//����ID/EXģ��������ִ�н׶�EXģ�������
	wire[`OpkindBus]      ex_alu_type;        //ָ���opcode
    wire[`OpcmdBus]       ex_alu_cmd;        //ָ��funct3
	
	wire[`RegBus]         ex_op_data1_i;
	wire[`RegBus]         ex_op_data2_i;
	wire                  ex_wreg_i;
	wire[`RegAddrBus]     ex_wd_i;
    wire[`RegBus]         ex_store_data_i;
	
	//����ִ�н׶�EXģ��������EX/MEMģ�������
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;
    
    wire[`MemAddrBus]      ex_mem_addr_o;
    wire[`OpkindBus]       ex_alu_type_o;
    wire[`OpcmdBus]        ex_alu_cmd_o;

	//����EX/MEMģ��������ô�׶�MEMģ�������
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
    
    wire[`MemAddrBus]      mem_mem_addr_i;
    wire[`OpkindBus]       mem_alu_type_i;
    wire[`OpcmdBus]        mem_alu_cmd_i;

	//���ӷô�׶�MEMģ��������MEM/WBģ�������
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	
	//����MEM/WBģ���������д�׶ε�����	
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	
	//��������׶�IDģ����ͨ�üĴ���Regfileģ��
    wire reg1_read;
    wire reg2_read;
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddrBus] reg1_addr;
    wire[`RegAddrBus] reg2_addr;
    
    //��֧ר����䣺
    //wire id_branch_flag;
    wire id_pc_branch_flag;
    wire[`RegBus] id_pc_branch_address;
    
    //����ģ��ר��
    wire[5:0] stall;
    wire      if_stallreq;
    //������
    wire      if_stallreq2;
    wire      id_stallreq;
    wire      ex_stallreq;
    wire      mem_stallreq;
    
    //����ģ������
    ctrl ctrl_0(
        .rst(rst),
        .stallreq_if(if_stallreq),
        .stallreq_if2(if_stallreq2),
        .stallreq_id(id_stallreq),
        .stallreq_ex(ex_stallreq),
        .stallreq_mem(mem_stallreq),
        .stall(stall)
    );
  
  //pc_reg����
	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.ce(rom_ce_o),
		.branch_flag_i(id_pc_branch_flag),
        .branch_target_address_i(id_pc_branch_address),
        .stall(stall)
	);
	
  assign rom_addr_o = pc;

  //IF/IDģ������
	if_id if_id0(
		.clk(clk),
		.rst(rst),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i),  
        .stall(stall),
        .if_stallreq(if_stallreq)
        //.branch_flag_i(id_branch_flag)
	);
	
	//����׶�IDģ��
	id id0(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
        
        //forwarding
        //����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),
        .ex_alu_type_i(ex_alu_type_o),  //�����п�ʼ
	    //���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),

		//�͵�regfile����Ϣ
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  

		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
	  
		//�͵�ID/EXģ�����Ϣ
		
		.alu_type_o(id_alu_type),
		.alu_cmd_o(id_alu_cmd),
		//.alu_funct7_o(id_alu_funct7),
		
		.op_data1_o(id_op_data1_o),
		.op_data2_o(id_op_data2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
        
        //��֧�ж���Ϣ
        .branch_flag_o(id_pc_branch_flag),
        .branch_target_address_o(id_pc_branch_address),
        
        //������Ϣ
        .if_stallreq(if_stallreq2),
        .id_stallreq(id_stallreq),
        
        //storeר������
        .store_data_o(id_store_data_o)
	);

  //ͨ�üĴ���Regfile����
	regfile regfile1(
		.clk (clk),
		.rst (rst),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	//ID/EXģ��
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),
		
		//������׶�IDģ�鴫�ݵ���Ϣ
		.id_alu_type(id_alu_type),
		.id_alu_cmd(id_alu_cmd),
		//.id_funct7(id_alu_funct7),

		.id_op_data1(id_op_data1_o),
		.id_op_data2(id_op_data2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
	
		//���ݵ�ִ�н׶�EXģ�����Ϣ
		.ex_alu_type(ex_alu_type),
		.ex_alu_cmd(ex_alu_cmd),

		.ex_op_data1(ex_op_data1_i),
		.ex_op_data2(ex_op_data2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
        
        //������Ϣ
        .stall(stall),
        
        //storeר��
        .store_data_i(id_store_data_o),
        .store_data_o(ex_store_data_i)
	);		
	
	//EXģ��
	ex ex0(
		.rst(rst),
	
		//�͵�ִ�н׶�EXģ�����Ϣ
		.alu_type_i(ex_alu_type),
        .alu_cmd_i(ex_alu_cmd),
        //.alu_funct7_i(ex_alu_funct7),

		.op_data1_i(ex_op_data1_i),
		.op_data2_i(ex_op_data2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
	  
	    //EXģ��������EX/MEMģ����Ϣ
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
        
        .mem_addr_o(ex_mem_addr_o),
        .alu_type_o(ex_alu_type_o),
        .alu_cmd_o(ex_alu_cmd_o),
		
        //������Ϣ
        .ex_stallreq(ex_stallreq),
        
        //storeר��
        .store_data_i(ex_store_data_i)
	);

  //EX/MEMģ��
  ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  
		//����ִ�н׶�EXģ�����Ϣ	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
        .ex_alu_type(ex_alu_type_o),
        .ex_alu_cmd(ex_alu_cmd_o),
        .ex_mem_addr(ex_mem_addr_o),
	

		//�͵��ô�׶�MEMģ�����Ϣ
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
        .mem_alu_type(mem_alu_type_i),
        .mem_alu_cmd(mem_alu_cmd_i),
        .mem_mem_addr(mem_mem_addr_i),

		//������Ϣ
        .stall(stall)
	);
	
  //MEMģ������
	mem mem0(
		.rst(rst),
	
		//����EX/MEMģ�����Ϣ	
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
        .alu_type_i(mem_alu_type_i),
        .alu_cmd_i(mem_alu_cmd_i),
        .mem_addr_i(mem_mem_addr_i),
	  
		//�͵�MEM/WBģ�����Ϣ
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
        
        //������Ϣ
        .mem_stallreq(mem_stallreq),
        //�͵�memory����Ϣ
        .mem_addr_o(ram_addr_o),
        .mem_we_o(ram_we_o),
        .mem_sel_o(ram_sel_o),
        .mem_data_o(ram_data_o),
        .mem_data_i(ram_data_i),
        .mem_ce_o(ram_ce_o)    
	);

  //MEM/WBģ��
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

		//���Էô�׶�MEMģ�����Ϣ	
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
	
		//�͵���д�׶ε���Ϣ
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
        
        //������Ϣ
        .stall(stall)
							       	
	);

endmodule