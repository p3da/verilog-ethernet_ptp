/*
Copyright (c) 2014-2018 Alex Forencich
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
 * FPGA top-level module
 */
module fpga (
    /*
     * Clock: 200MHz
     * Reset: Push button, active high
     */
    input  wire       sys_clk_p,
    input  wire       sys_clk_n,
    input  wire       reset,
    /*
     * GPIO
     */
    // input  wire       btnu,
    // input  wire       btnl,
    // input  wire       btnd,
    // input  wire       btnr,
    // input  wire       btnc,
    // input  wire [7:0] sw,
    // output wire       ledu,
    // output wire       ledl,
    // output wire       ledd,
    // output wire       ledr,
    // output wire       ledc,
    output wire [7:0] led,
    /*
     * Ethernet: 1000BASE-T RGMII
     */
    input  wire       phy_rx_clk,
    input  wire [3:0] phy_rxd,
    input  wire       phy_rx_ctl,
    output wire       phy_tx_clk,
    output wire [3:0] phy_txd,
    output wire       phy_tx_ctl,
    output wire       phy_reset_n,
    /*
     * Silicon Labs CP2103 USB UART
     */
    output wire       uart_txd,
    input  wire       uart_rxd,
    input  wire       uart_rts,
    output wire       uart_cts
);

// Clock and reset

wire sys_clk_ibufg;
wire sys_clk_bufg;
wire clk_125mhz_mmcm_out;
wire clk90_125mhz_mmcm_out;
wire clk_250mhz_mmcm_out;

// Internal 125 MHz clock
wire clk_125mhz_int;
wire clk90_125mhz_int;
wire rst_125mhz_int;
wire clk_250mhz_int;
wire rst_250mhz_int;

wire mmcm_rst = reset;
wire mmcm_locked;
wire mmcm_clkfb;

// IBUFGDS
// clk_ibufgds_inst(
//     .I(sys_clk_p),
//     .IB(sys_clk_n),
//     .O(sys_clk_ibufg)
// );
//Differential to single ended clock conversion
IBUFGDS
	#(
		.IOSTANDARD("LVDS"),
		.DIFF_TERM("FALSE"),
		.IBUF_LOW_PWR("FALSE"))
i_sysclk_iobuf
	(
	 .I(sys_clk_p),
	 .IB(sys_clk_n),
	 .O(sys_clk_ibufg)
	 );

// MMCM instance
// 300 MHz in, 125 MHz out ---250 in auf avnet
// PFD range: 10 MHz to 450 MHz
// VCO range: 600 MHz to 1200 MHz
// M = 5, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
MMCM_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(12),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(12),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(90),
    .CLKOUT2_DIVIDE(8),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(5),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(3.333),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(sys_clk_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_125mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(clk90_125mhz_mmcm_out),
    .CLKOUT1B(),
    .CLKOUT2(clk_250mhz_mmcm_out),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_125mhz_bufg_inst (
    .I(clk_125mhz_mmcm_out),
    .O(clk_125mhz_int)
);

BUFG
clk90_125mhz_bufg_inst (
    .I(clk90_125mhz_mmcm_out),
    .O(clk90_125mhz_int)
);

BUFG
clk_250mhz_bufg_inst (
    .I(clk_250mhz_mmcm_out),
    .O(clk_250mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~mmcm_locked),
    .out(rst_125mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_250mhz_inst (
    .clk(clk_250mhz_int),
    .rst(~mmcm_locked),
    .out(rst_250mhz_int)
);

// GPIO
// wire btnu_int;
// wire btnl_int;
// wire btnd_int;
// wire btnr_int;
// wire btnc_int;
// wire [7:0] sw_int;
//
// wire ledu_int;
// wire ledl_int;
// wire ledd_int;
// wire ledr_int;
// wire ledc_int;
wire [7:0] led_int;

wire uart_rxd_int;
wire uart_txd_int;
wire uart_rts_int;
wire uart_cts_int;

wire rx_eth_hdr_ready_MB;
wire rx_eth_hdr_valid_MB;
wire [47:0] rx_eth_dest_mac_MB;
wire [47:0] rx_eth_src_mac_MB;
wire [15:0] rx_eth_type_MB;
wire [7:0] rx_eth_payload_axis_tdata_MB;
wire rx_eth_payload_axis_tvalid_MB;
wire rx_eth_payload_axis_tready_MB;
wire rx_eth_payload_axis_tlast_MB;
wire rx_eth_payload_axis_tuser_MB;

wire tx_eth_hdr_ready_MB;
wire tx_eth_hdr_valid_MB;
wire [47:0] tx_eth_dest_mac_MB;
wire [47:0] tx_eth_src_mac_MB;
wire [15:0] tx_eth_type_MB;
wire [7:0] tx_eth_payload_axis_tdata_MB;
wire tx_eth_payload_axis_tvalid_MB;
wire tx_eth_payload_axis_tready_MB;
wire tx_eth_payload_axis_tlast_MB;
wire tx_eth_payload_axis_tuser_MB;

wire [95:0] m_axis_tx_ptp_ts_96;
wire m_axis_tx_ptp_ts_valid;
wire m_axis_tx_ptp_ts_ready;

wire [95:0] m_axis_rx_ptp_ts_96;
wire m_axis_rx_ptp_ts_valid;
wire m_axis_rx_ptp_ts_ready;

// debounce_switch #(
//     .WIDTH(13),
//     .N(4),
//     .RATE(125000)
// )
// debounce_switch_inst (
//     .clk(clk_125mhz_int),
//     .rst(rst_125mhz_int),
//     .in({btnu,
//         btnl,
//         btnd,
//         btnr,
//         btnc,
//         sw}),
//     .out({btnu_int,
//         btnl_int,
//         btnd_int,
//         btnr_int,
//         btnc_int,
//         sw_int})
// );

sync_signal #(
    .WIDTH(2),
    .N(2)
)
sync_signal_inst (
    .clk(clk_125mhz_int),
    .in({uart_txd,
        uart_rts}),
    .out({uart_txd_int,
        uart_rts_int})
);

// assign ledu = ledu_int;
// assign ledl = ledl_int;
// assign ledd = ledd_int;
// assign ledr = ledr_int;
// assign ledc = ledc_int;
assign led = led_int;

assign uart_rxd = uart_rxd_int;
assign uart_cts = uart_cts_int;

fpga_core
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk_125mhz(clk_125mhz_int),
    .clk90_125mhz(clk90_125mhz_int),
    .rst_125mhz(rst_125mhz_int),

    /*
     * Clock: 250 MHz
     * Synchronous reset
     */
    .clk_250mhz(clk_250mhz_int),
    .rst_250mhz(rst_250mhz_int),

    /*
     * GPIO
     */
    // .btnu(btnu_int),
    // .btnl(btnl_int),
    // .btnd(btnd_int),
    // .btnr(btnr_int),
    // .btnc(btnc_int),
    // .sw(sw_int),
    // .ledu(ledu_int),
    // .ledl(ledl_int),
    // .ledd(ledd_int),
    // .ledr(ledr_int),
    // .ledc(ledc_int),
    .led(led_int),
    /*
     * Ethernet: 1000BASE-T RGMII
     */
    .phy_rx_clk(phy_rx_clk),
    .phy_rxd(phy_rxd),
    .phy_rx_ctl(phy_rx_ctl),
    .phy_tx_clk(phy_tx_clk),
    .phy_txd(phy_txd),
    .phy_tx_ctl(phy_tx_ctl),
    .phy_reset_n(phy_reset_n),
    /*
     * UART: 115200 bps, 8N1
     */


    /* Ethernet TX interface */
    .s_eth_payload_axis_tdata(tx_eth_payload_axis_tdata_MB),
    .s_eth_payload_axis_tvalid(tx_eth_payload_axis_tvalid_MB),
    .s_eth_payload_axis_tready(tx_eth_payload_axis_tready_MB),
    .s_eth_payload_axis_tlast(tx_eth_payload_axis_tlast_MB),
    .s_eth_payload_axis_tuser(tx_eth_payload_axis_tuser_MB),

    /* Ethernet RX interface */
    .m_eth_payload_axis_tdata(rx_eth_payload_axis_tdata_MB),
    .m_eth_payload_axis_tvalid(rx_eth_payload_axis_tvalid_MB),
    .m_eth_payload_axis_tready(rx_eth_payload_axis_tready_MB),
    .m_eth_payload_axis_tlast(rx_eth_payload_axis_tlast_MB),
    .m_eth_payload_axis_tuser(rx_eth_payload_axis_tuser_MB),

    /*
     * Transmit timestamp output
     */
    .m_axis_tx_ptp_ts_96(m_axis_tx_ptp_ts_96),
    .m_axis_tx_ptp_ts_valid(m_axis_tx_ptp_ts_valid),
    .m_axis_tx_ptp_ts_ready(m_axis_tx_ptp_ts_ready),

    /*
     * Receive timestamp output
     */
    .m_axis_rx_ptp_ts_96(m_axis_rx_ptp_ts_96),
    .m_axis_rx_ptp_ts_valid(m_axis_rx_ptp_ts_valid),
    .m_axis_rx_ptp_ts_ready(m_axis_rx_ptp_ts_ready),

    /*
     * PTP clock
     */
    .ptp_ts_96()
);

MicroBlaze MicroBlaze_i
   (.clk_125MHz(clk_125mhz_int),
    .reset(rst_125mhz_int),
    .reset_n(~rst_125mhz_int),

    /* PTP Timestamp interfaces */
    .rx_ptp_ts_96_0(m_axis_rx_ptp_ts_96),
    .tx_ptp_ts_96_0(m_axis_tx_ptp_ts_96),
    .rx_ptp_ts_ready_0(m_axis_rx_ptp_ts_ready),
    .rx_ptp_ts_valid_0(m_axis_rx_ptp_ts_valid),
    .tx_ptp_ts_ready_0(m_axis_tx_ptp_ts_ready),
    .tx_ptp_ts_valid_0(m_axis_tx_ptp_ts_valid),

    /* Ethernet frame RX interfaces */
    .axi_str_rxd_tdata_0(rx_eth_payload_axis_tdata_MB),
    .axi_str_rxd_tlast_0(rx_eth_payload_axis_tlast_MB),
    .axi_str_rxd_tready_0(rx_eth_payload_axis_tready_MB),
    .axi_str_rxd_tvalid_0(rx_eth_payload_axis_tvalid_MB),

    /* Ethernet frame TX interfaces */
    .axi_str_txd_tdata_0(tx_eth_payload_axis_tdata_MB),
    .axi_str_txd_tlast_0(tx_eth_payload_axis_tlast_MB),
    .axi_str_txd_tready_0(tx_eth_payload_axis_tready_MB),
    .axi_str_txd_tvalid_0(tx_eth_payload_axis_tvalid_MB),

    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd)
);

endmodule
