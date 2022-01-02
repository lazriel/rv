// **********************************************************************
// Technion EE 044252: Digital Systems and Computer Structure course    *
// Simple Multicycle RISC-V model                                       *
// ==============================                                       *
// Data path                                                            *
// **********************************************************************
 module rv_dp
    #(parameter
        DPWIDTH = 32,
        RFSIZE  = 32
    )
 (

     // Memory interface
     output wire [DPWIDTH-1:0] imem_addr,
     output wire [DPWIDTH-1:0] dmem_addr,
     output wire [DPWIDTH-1:0] dmem_dataout,
     input wire [DPWIDTH-1:0] dmem_datain,
     input wire [DPWIDTH-1:0] imem_datain,

     // Interface with control logic
     output wire [DPWIDTH-1:0] instr,
     output wire zero,
     input wire pcsourse,
     input wire pcwrite,
     input wire pccen,
     input wire irwrite,
     input wire [1:0] wbsel,
     input wire regwen,
     input wire [1:0] immsel,
     input wire asel,
     input wire bsel,
     input wire [3:0] alusel,
     input wire mdrwrite,
     
     // Clock and reset
     input wire clk,
     input wire rst
 );

 // Design parameters
 `include "params.inc"

 // Stage registers
 reg [DPWIDTH-1:0] pc, pcc, ir, a, b, aluout, mdr;

 // Fetch
 assign imem_addr = pc;

 // PC
 // ==
 always @(posedge clk or posedge rst)
     if (rst)
         pc     <= 0;
     else if (pcwrite)
         pc     <= (pcsourse == PC_ALU) ? aluout : pc + 4;
 
 // PCC
 // ===
 always @(posedge clk or posedge rst)
     if (rst)
         pcc    <= 0;
     else if (pccen)
         pcc    <= pc;
 
 // IR
 // ==
 always @(posedge clk or posedge rst)
     if (rst)
         ir     <= 0;
     else if (irwrite)
         ir     <= imem_datain;
 assign instr = ir;
 
 // Register file inputs
 // ====================
 reg [DPWIDTH-1:0] datad;
 always @(*)
    case (wbsel)
        WB_MDR:     datad = mdr;
        WB_ALUOUT:  datad = aluout;
        WB_PC:      datad = pc;
        default:    datad = pc;
    endcase
 wire [4:0] addra = ir[19:15];
 wire [4:0] addrb = ir[24:20];
 wire [4:0] addrd = ir[11:7];

 
 // Register File
 // =============
 reg [DPWIDTH-1:0] rf [RFSIZE-1:1];

 wire regwen1 = regwen && (addrd != 0); // X0 is constant 0
 always @(posedge clk)
     if (regwen1)
         rf[addrd]    <= datad;

 always @(posedge clk or posedge rst)
     if (rst)
     begin
         a      <= 0;
         b      <= 0;
     end
     else
     begin
         a      <= (addra == 0) ? 0 : rf[addra];
         b      <= (addrb == 0) ? 0 : rf[addrb];
     end

 // ALU
 // ===
 
 // Immediate selector
 reg [DPWIDTH-1:0] imm;
 always @(*)
 begin
     case(immsel)
         IMM_J: imm = {{12{ir[31]}},ir[19:12],ir[20],ir[30:21],1'b0};
         IMM_B: imm = {{20{ir[31]}},ir[7],ir[30:25],ir[11:8],1'b0};
         IMM_S: imm = {{21{ir[31]}},ir[30:25],ir[11:7]};
         IMM_L: imm = {{21{ir[31]}},ir[30:20]};
     endcase
 end

 // ALU input A
 wire [DPWIDTH-1:0] alu_a = (asel == ALUA_REG) ? a : pcc;

 // ALU input A
 wire [DPWIDTH-1:0] alu_b = (bsel == ALUB_REG) ? b : imm;

 // For signed comparison, cast to integer. reg is by default unsigned
 integer alu_as;
 always @(*) alu_as = alu_a;
 integer alu_bs;
 always @(*) alu_bs = alu_b;

 // The ALU
 reg [DPWIDTH-1:0] alu_result;
 always @(*)
     case (alusel)
         ALU_ADD: alu_result = alu_a + alu_b;
         ALU_SUB: alu_result = alu_a - alu_b;
         ALU_SLL: alu_result = alu_a << alu_b;
         ALU_SLT: alu_result = (alu_as < alu_bs) ? 1 : 0;
         ALU_SLTU:alu_result = (alu_a < alu_b) ? 1 : 0;
         ALU_XOR: alu_result = alu_a ^ alu_b;
         ALU_SRL: alu_result = alu_a >> alu_b;
         ALU_SRA: alu_result = alu_a >>> alu_b;
         ALU_OR : alu_result = alu_a | alu_b;
         ALU_AND: alu_result = alu_a & alu_b;
         default: alu_result = alu_a + alu_b;
     endcase

 assign zero = (alu_result == 0);

 always @(posedge clk or posedge rst)
     if (rst)
         aluout     <= 0;
     else
         aluout     <= alu_result;


 // Memory
 // ======
 assign dmem_addr = aluout;
 assign dmem_dataout = b;

 always @(posedge clk or posedge rst)
     if (rst)
         mdr    <= 0;
     else if (mdrwrite)
         mdr    <= dmem_datain;

endmodule


