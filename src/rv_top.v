// **********************************************************************
// Technion EE 044252: Digital Systems and Computer Structure course    *
// Simple Multicycle RISC-V model                                       *
// ==============================                                       *
// Top level                                                            *
// **********************************************************************

 module rv_top
    #(parameter
        DPWIDTH = 32,
        RFSIZE  = 32
    )
 (

     // Memory interface
     output wire [DPWIDTH-1:0] imem_addr,
     output wire [DPWIDTH-1:0] dmem_addr,
     output wire [DPWIDTH-1:0] dmem_dataout,
     output wire memrw,
     input wire [DPWIDTH-1:0] dmem_datain,
     input wire [DPWIDTH-1:0] imem_datain,

     // Clock and reset
     input wire clk,
     input wire rst
 );


 // Interconnect wire declarations
 // ==============================
 wire [DPWIDTH-1:0] instr;
 wire zero;
 wire pcsourse;
 wire pcwrite;
 wire pccen;
 wire irwrite;
 wire [1:0] wbsel;
 wire regwen;
 wire [1:0] immsel;
 wire asel;
 wire bsel;
 wire [3:0] alusel;
 wire mdrwrite;
     
 // Data path
 // =========
 rv_dp
    #(
        .DPWIDTH(DPWIDTH),
        .RFSIZE(RFSIZE)
    ) dp
 (

     // Memory interface
     .imem_addr(imem_addr),
     .dmem_addr(dmem_addr),
     .dmem_dataout(dmem_dataout),
     .dmem_datain(dmem_datain),
     .imem_datain(imem_datain),

     // Interface with control logic
     .instr(instr),
     .zero(zero),
     .pcsourse(pcsourse),
     .pcwrite(pcwrite),
     .pccen(pccen),
     .irwrite(irwrite),
     .wbsel(wbsel),
     .regwen(regwen),
     .immsel(immsel),
     .asel(asel),
     .bsel(bsel),
     .alusel(alusel),
     .mdrwrite(mdrwrite),
     
     // Clock and reset
     .clk(clk),
     .rst(rst)
 );

 // Control
 // =======
 rv_ctl ctl
 (

     // Output to memory
     .memrw(memrw),

     // Interface with datapath
     .instr(instr),
     .zero(zero),
     .pcsourse(pcsourse),
     .pcwrite(pcwrite),
     .pccen(pccen),
     .irwrite(irwrite),
     .wbsel(wbsel),
     .regwen(regwen),
     .immsel(immsel),
     .asel(asel),
     .bsel(bsel),
     .alusel(alusel),
     .mdrwrite(mdrwrite),
     
     // Clock and reset
     .clk(clk),
     .rst(rst)
 );
 
 endmodule
