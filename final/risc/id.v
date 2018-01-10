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
// Module:  id
// File:    id.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: ����׶�
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module id(

	input wire					  rst,             //��λ�ź�
	input wire[`InstAddrBus]	  pc_i,            //ָ���Ӧ��ַ
	input wire[`InstBus]          inst_i,          //ָ������

	input wire[`RegBus]           reg1_data_i,     //�ӵ�һ���Ĵ�����ֵ
	input wire[`RegBus]           reg2_data_i,     //�ڶ����Ĵ���
    
    //forwarding
    //ִ�н׶ε�ָ��
    input wire                    ex_wreg_i,         //�Ƿ�Ҫд��Ĵ���
    input wire[`RegAddrBus]       ex_wd_i,           //д��ĵ�ַ
    input wire[`RegBus]           ex_wdata_i,        //д������
    input wire[`OpkindBus]         ex_alu_type_i,     //����ִ�еĲ�������
    
    //�����ڴ�׶ε�ָ��
    input wire                    mem_wreg_i,         //�Ƿ�Ҫд��Ĵ���
    input wire[`RegAddrBus]       mem_wd_i,           //д��ĵ�ַ
    input wire[`RegBus]           mem_wdata_i,        //д������

	//�͵�regfile����Ϣ
	output reg                    reg1_read_o,     //��һ���Ĵ�����ʹ�ܶ��ź�
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,     //��ȡ�ĵ�ַ��ʲô
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	//�͵�ִ�н׶ε���Ϣ
    output reg[`OpkindBus]        alu_type_o,
    output reg[`OpcmdBus]         alu_cmd_o,

	output reg[`RegBus]           op_data1_o,          //ȡ�����Ĳ��������������ݣ�
	output reg[`RegBus]           op_data2_o,
	output reg[`RegAddrBus]       wd_o,                //Ҫд���Ŀ�ĵؼĴ���
	output reg                    wreg_o,              //�Ƿ�Ҫд��Ŀ�ļĴ���
    
    //��תָ��
    output reg[`InstAddrBus]      branch_target_address_o,
    output reg                    branch_flag_o,
    
    output wire                   if_stallreq,
    output wire                   id_stallreq, 
    
    //Ϊ�о��Ƿ��Ƕ��������⣬����·ֱ�Ӹĵ�
    /*output reg                   if_stallreq,
    output reg                   id_stallreq,*/
    
    //����storeָ��
    output reg[`RegBus]           store_data_o
);

  wire[`InstBus] inst_use = {inst_i[7:0],inst_i[15:8],inst_i[23:16], inst_i[31:24]};
  wire[6:0] op = inst_use[6:0];
  wire[3:0] funct3 = inst_use[14:12];
  wire funct7 = inst_use[30];
  wire[`InstAddrBus] pc_plus_4 = pc_i + 4;
  /*wire[`OpcodeBus] op;
  wire[`Funct3Bus] funct3; 
  wire funct7; 
  assign {op, funct3, funct7}= {inst_use[6:0],inst_use[14:12],inst_use[30]};*/
  
  reg[`RegBus] imm;   //�˴���Ҫ�޸ģ�ע��RISC-V�����е���������Ϊ�з�����չ���ο��ĵ�11ҳ��
  reg instvalid;
  reg stallreq_from_branch;
  reg stallreq_for_reg1_loadrelate;
  reg stallreq_for_reg2_loadrelate;
  
  assign if_stallreq =  stallreq_from_branch;
  assign id_stallreq =  stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
  
  /*always @ (*) begin
        if (rst == `RstEnable) begin
            if_stallreq <= `NoStop;
            id_stallreq <= `NoStop;
        end else begin
            if_stallreq <= stallreq_from_branch;
            id_stallreq <=  stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
        end
  end*/
  
 
  wire [`RegBus] imm_address = pc_i + { {20{inst_use[31]}}, {inst_use[7]}, {inst_use[30:25]}, {inst_use[11:8]}, 1'b0};
    
 
    //һ��Ϊ�������ݶ�ȡ�Ĳ���
	always @ (*) begin	
		if (rst == `RstEnable) begin
		    //��λ�źŵĴ���
            
			wd_o <= `NONRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NONRegAddr;
			reg2_addr_o <= `NONRegAddr;
			imm <= `ZeroWord;

	  end 
	  else begin
            wd_o <= inst_use[11:7];
            wreg_o <= `WriteDisable;
            instvalid <= `InstInvalid;	   //Ӧ����Ϊ���洦���쳣���̵�
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_use[19:15];
            reg2_addr_o <= inst_use[24:20];            
            imm <= `ZeroWord;
            //branch_flag_o <= `NotBranch;
            //branch_target_address_o <= `NONRegAddr;
            
            case (op)
                 //�˴���Ҫ�޸�
                `OP_OP_IMM:	 begin                        //ORIָ��
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
                    imm <= { {20{inst_use[31]}}, {inst_use[31:20]} };
                    instvalid <= `InstValid;	
                end
                `OP_OP: begin
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
                    imm <= `ZeroWord;
                    instvalid <= `InstValid;
                end
                `OP_LUI: begin
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
                    imm <= {inst_use[31:12] , 12'b000000000000 };
                    instvalid <= `InstValid;
                 end
                `OP_AUIPC: begin
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
                    imm <= {inst_use[31:12] , 12'b000000000000 } + pc_i;
                    instvalid <= `InstValid;
                end
                `OP_JAL: begin
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
                    imm <= pc_plus_4;
                    instvalid <= `InstValid;
                end
                `OP_JALR: begin
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
                    imm <= pc_plus_4;
                    instvalid <= `InstValid;
                end
                `OP_BRANCH: begin
                    wreg_o <= `WriteDisable;
                    reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
                    imm <= `ZeroWord;
                    instvalid <= `InstValid;
                end
                `OP_LOAD: begin
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
                    store_data_o <= { {20{inst_use[31]}}, {inst_use[31:20]}};
                    imm <= `ZeroWord;
                    instvalid <= `InstValid;
                end
                `OP_STORE: begin
                    wreg_o <= `WriteDisable;
                    reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
                    store_data_o <= { {20{inst_use[31]}}, inst_use[31:25], inst_use[11:7]};
                    imm <= `ZeroWord;
                    instvalid <= `InstValid;
                end 
                
                
            default:			begin
                /*wreg_o <= `WriteDisable;
               // instvalid <= `InstInvalid;       //Ӧ����Ϊ���洦���쳣���̵�
                instvalid <= `InstValid;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                imm <= `ZeroWord;*/
            end
            
            endcase		  		
		end      
	end 
    
    
    always @ (*) begin
        if (rst == `RstEnable) begin
		    //��λ�źŵĴ���
            alu_cmd_o <= `EXE_NON_OP;
            alu_type_o <= `EXE_NON_TYPE;
            branch_flag_o <= `NotBranch;
            branch_target_address_o <= `ZeroWord;
            stallreq_from_branch <= 1'b0;
        end
        else begin
            alu_cmd_o <= `EXE_NON_OP;
            alu_type_o <= `EXE_NON_TYPE;
            branch_flag_o <= `NotBranch;
            branch_target_address_o <= `ZeroWord;
            stallreq_from_branch <= 1'b0;
            case (op)
                `OP_OP, `OP_OP_IMM: begin
                    stallreq_from_branch <= 1'b0;
                    branch_flag_o <= `NotBranch;
                    branch_target_address_o <= `ZeroWord;
                    case (funct3)
                        `FUNCT3_ADD_SUB: begin
                            if ((funct7 == `FUNCT7_SUB) && (op == `OP_OP)) begin
                                alu_cmd_o <= `EXE_SUB;
                            end
                            else begin
                            alu_cmd_o <= `EXE_ADD;
                            end
                            alu_type_o <= `EXE_ARITHMETIC_TYPE;
                        end
                        `FUNCT3_SLL: begin 
                            alu_cmd_o <= `EXE_SLL;
                            alu_type_o <= `EXE_SHIFT_TYPE;
                            end     
                        `FUNCT3_SLT: begin
                            alu_cmd_o <= `EXE_SLT;
                            alu_type_o <= `EXE_ARITHMETIC_TYPE;
                            end    
                        `FUNCT3_SLTU: begin 
                            alu_cmd_o <= `EXE_SLTU;
                            alu_type_o <= `EXE_ARITHMETIC_TYPE;
                            end    
                        `FUNCT3_XOR: begin
                            alu_cmd_o <= `EXE_XOR;
                            alu_type_o <= `EXE_LOGIC_TYPE;
                            end   
                        `FUNCT3_SRL_SRA: begin 
                            alu_type_o <= `EXE_SHIFT_TYPE;
                            if (funct7 == `FUNCT7_SRA) alu_cmd_o <= `EXE_SRA;
                            else alu_cmd_o <= `EXE_SRL;
                            end                        
                        `FUNCT3_OR: begin 
                            alu_cmd_o <= `EXE_OR;
                            alu_type_o <= `EXE_LOGIC_TYPE;
                            end
                        `FUNCT3_AND: begin 
                            alu_cmd_o <= `EXE_AND;
                            alu_type_o <= `EXE_LOGIC_TYPE;
                            end     
                        default: begin 
                        end
                        
                    endcase
                end
                
                `OP_LUI,`OP_AUIPC: begin
                    stallreq_from_branch <= 1'b0;
                    branch_flag_o <= `NotBranch;
                    branch_target_address_o <= `ZeroWord;
                    //��һ����д�Ĵ����ĸ�ʽ
                    alu_type_o <= `EXE_JUMP_TYPE;
                end
                
                `OP_JAL: begin
                    alu_type_o <= `EXE_JUMP_TYPE;
                    alu_cmd_o <= `EXE_NON_OP;
                    branch_flag_o <= `Branch;
                    branch_target_address_o <= pc_i + {{12{inst_use[31]}}, {inst_use[19:12]}, {inst_use[20]}, {inst_use[30:21]}, 1'b0};
                    stallreq_from_branch <= `Stop;
                end
                
                `OP_JALR: begin
                    alu_type_o <= `EXE_JUMP_TYPE;
                    alu_cmd_o <= `EXE_NON_OP;
                    branch_flag_o <= `Branch;
                    branch_target_address_o <= op_data1_o + {{20{inst_use[31]}}, {inst_use[31:20]}};
                    stallreq_from_branch <= `Stop;
                end
                
                `OP_BRANCH: begin
                    // $display("reg1:%b, reg2:%b",op_data1_o,op_data2_o);
                    alu_type_o <= `EXE_JUMP_TYPE;
                    alu_cmd_o <= `EXE_NON_OP;
                    case(funct3)
                         `FUNCT3_BEQ: begin
                            if (op_data1_o == op_data2_o) begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= imm_address;
                                stallreq_from_branch <= `Stop;
                            end
                        end
                        `FUNCT3_BNE: begin
                           if (op_data1_o != op_data2_o) begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= imm_address;
                                stallreq_from_branch <= `Stop;
                                //$display("bne: reg1:%b, reg2:%b",op_data1_o,op_data2_o);
                            end
                        end
                        `FUNCT3_BLTU:  begin
                            if (op_data1_o < op_data2_o) begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= imm_address;
                                stallreq_from_branch <= `Stop;
                            end
                        end
                        
                         `FUNCT3_BGEU: begin
                            if (op_data1_o >= op_data2_o) begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= imm_address;
                                stallreq_from_branch <= `Stop;
                            end
                        end
                        
                         `FUNCT3_BLT: begin
                            //$display("blt: reg1:%h, reg2:%h",op_data1_o,op_data2_o);
                            if ( (op_data1_o[31] && !op_data2_o[31]) 
                            || (!op_data1_o[31] && !op_data2_o[31] && (op_data1_o < op_data2_o) )
                            || (op_data1_o[31] && op_data2_o[31] && ( (~op_data1_o)+1 > (~op_data2_o)+1 ))) begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= imm_address;
                                stallreq_from_branch <= `Stop;
                                //$display("blt: reg1:%h, reg2:%h",op_data1_o,op_data2_o);
                            end
                        end
                        
                        `FUNCT3_BGE: begin
                            if ( (!op_data1_o[31] && op_data2_o[31]) 
                            || (!op_data1_o[31] && !op_data2_o[31] && (op_data1_o >= op_data2_o) )
                            || (op_data1_o[31] && op_data2_o[31] && ( (~op_data1_o)+1 <= (~op_data2_o)+1 ))) begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= imm_address;
                                stallreq_from_branch <= `Stop;
                                //$display("bge: reg1:%b, reg2:%b",op_data1_o,op_data2_o);
                            end
                        end

                        default: begin
                        end
                    endcase
                end
                
                `OP_LOAD: begin
                    branch_flag_o <= `NotBranch;
                    branch_target_address_o <= `ZeroWord;
                    stallreq_from_branch <= 1'b0;
                    alu_type_o <= `EXE_LOAD_TYPE;
                    case (funct3)
                        `FUNCT3_LB: begin
                            alu_cmd_o <= `EXE_LB;
                        end
                        `FUNCT3_LH: begin
                            alu_cmd_o <= `EXE_LH;
                        end
                        `FUNCT3_LW: begin
                            alu_cmd_o <= `EXE_LW;
                        end
                        `FUNCT3_LBU: begin
                            alu_cmd_o <= `EXE_LBU;
                        end
                        `FUNCT3_LHU: begin
                            alu_cmd_o <= `EXE_LHU;
                        end
                    endcase
                end
                `OP_STORE: begin
                    branch_flag_o <= `NotBranch;
                    branch_target_address_o <= `ZeroWord;
                    stallreq_from_branch <= 1'b0;
                    alu_type_o <= `EXE_STORE_TYPE;
                    case (funct3)
                        `FUNCT3_SB: begin
                            alu_cmd_o <= `EXE_SB;
                        end
                        `FUNCT3_SH: begin
                            alu_cmd_o <= `EXE_SH;
                        end
                        `FUNCT3_SW: begin
                            alu_cmd_o <= `EXE_SW;
                        end
                    endcase
                end
                
                default: begin
                    /*alu_cmd_o <= `EXE_NON_OP;
                    alu_type_o <= `EXE_NON_TYPE;
                    branch_flag_o <= `NotBranch;
                    branch_target_address_o <= `ZeroWord;
                    stallreq_from_branch <= 1'b0;*/
                end
            endcase
        end
    end
	

	always @ (*) begin
      stallreq_for_reg1_loadrelate <= `NoStop;
      if(rst == `RstEnable) begin
		 op_data1_o <= `ZeroWord;
      //���load��ͻ
      end else if(ex_alu_type_i == `EXE_LOAD_TYPE && ex_wd_i == reg1_addr_o 
								&& reg1_read_o == 1'b1 ) begin
		  stallreq_for_reg1_loadrelate <= `Stop;
	  end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
                            && (ex_wd_i == reg1_addr_o) && (ex_wd_i != `ZeroWord)) begin
         op_data1_o <= ex_wdata_i; 
      end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
                            && (mem_wd_i == reg1_addr_o) && (mem_wd_i != `ZeroWord)) begin
         op_data1_o <= mem_wdata_i;             
	  end else if(reg1_read_o == 1'b1) begin
	  	 op_data1_o <= reg1_data_i;
	  end else if(reg1_read_o == 1'b0) begin
	  	 op_data1_o <= imm;
	  end else begin
	     op_data1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
      stallreq_for_reg2_loadrelate <= `NoStop;
      if(rst == `RstEnable) begin
         op_data2_o <= `ZeroWord;
      end else if(ex_alu_type_i == `EXE_LOAD_TYPE && ex_wd_i == reg2_addr_o 
								&& reg2_read_o == 1'b1 ) begin
		  stallreq_for_reg2_loadrelate <= `Stop;
      end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
                           && (ex_wd_i == reg2_addr_o) && (ex_wd_i != `ZeroWord)) begin
         op_data2_o <= ex_wdata_i; 
      end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
                           && (mem_wd_i == reg2_addr_o)&& (mem_wd_i != `ZeroWord)) begin
         op_data2_o <= mem_wdata_i;  
      end else if(reg2_read_o == 1'b1) begin
         op_data2_o <= reg2_data_i;
      end else if(reg2_read_o == 1'b0) begin
         op_data2_o <= imm;
      end else begin
         op_data2_o <= `ZeroWord;
      end
	end

endmodule
/*alu_opcode_o <= `OP_NON;
            alu_funct3_o <= `FUNCT3_NON;
            alu_funct7_o <= `FUNCT7_NON;*/