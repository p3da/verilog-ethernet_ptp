/*

Copyright (c) 2015-2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Testbench for fpga_core
 */
module test_fpga_core;

// Parameters
parameter TARGET = "SIM";

// Inputs
reg clk_125mhz = 0;
reg clk90_125mhz = 0;
reg rst_125mhz = 0;
reg [7:0] current_test = 0;

reg btnu = 0;
reg btnl = 0;
reg btnd = 0;
reg btnr = 0;
reg btnc = 0;
reg [7:0] sw = 0;
reg phy_rx_clk = 0;
reg [3:0] phy_rxd = 0;
reg phy_rx_ctl = 0;
reg uart_txd = 0;
reg uart_rts = 0;

// Outputs
wire ledu;
wire ledl;
wire ledd;
wire ledr;
wire ledc;
wire [7:0] led;
wire phy_tx_clk;
wire [3:0] phy_txd;
wire phy_tx_ctl;
wire phy_reset_n;
wire uart_rxd;
wire uart_cts;

initial begin
    // myhdl integration
    $from_myhdl(
        clk_125mhz,
        clk90_125mhz,
        rst_125mhz,
        current_test,
        btnu,
        btnl,
        btnd,
        btnr,
        btnc,
        sw,
        phy_rx_clk,
        phy_rxd,
        phy_rx_ctl,
        uart_txd,
        uart_rts
    );
    $to_myhdl(
        ledu,
        ledl,
        ledd,
        ledr,
        ledc,
        led,
        phy_tx_clk,
        phy_txd,
        phy_tx_ctl,
        phy_reset_n,
        uart_rxd,
        uart_cts
    );

    // dump file
    $dumpfile("test_fpga_core.lxt");
    $dumpvars(0, test_fpga_core);
end

fpga_core #(
    .TARGET(TARGET)
)
UUT (
    .clk_125mhz(clk_125mhz),
    .clk90_125mhz(clk90_125mhz),
    .rst_125mhz(rst_125mhz),
    .btnu(btnu),
    .btnl(btnl),
    .btnd(btnd),
    .btnr(btnr),
    .btnc(btnc),
    .sw(sw),
    .ledu(ledu),
    .ledl(ledl),
    .ledd(ledd),
    .ledr(ledr),
    .ledc(ledc),
    .led(led),
    .phy_rx_clk(phy_rx_clk),
    .phy_rxd(phy_rxd),
    .phy_rx_ctl(phy_rx_ctl),
    .phy_tx_clk(phy_tx_clk),
    .phy_txd(phy_txd),
    .phy_tx_ctl(phy_tx_ctl),
    .phy_reset_n(phy_reset_n),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd),
    .uart_rts(uart_rts),
    .uart_cts(uart_cts)
);

endmodule
