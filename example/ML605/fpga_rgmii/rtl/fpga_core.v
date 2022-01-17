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
 * FPGA core logic
 */
module fpga_core #
(
    parameter TARGET = "XILINX",
    parameter PTP_TS_WIDTH = 96
)
(
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    input  wire       clk_125mhz,
    input  wire       clk90_125mhz,
    input  wire       rst_125mhz,

    /*
     * Clock: 250 MHz
     * Synchronous reset
     */
    input  wire       clk_250mhz,
    input  wire       rst_250mhz,

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


     // Ethernet frame input
    input  wire [7:0]            s_eth_payload_axis_tdata,
    input  wire                  s_eth_payload_axis_tkeep,
    input  wire                  s_eth_payload_axis_tvalid,
    output wire                  s_eth_payload_axis_tready,
    input  wire                  s_eth_payload_axis_tlast,
    input  wire                  s_eth_payload_axis_tuser,

     /*
     * Ethernet frame output
     */
    output wire [7:0]            m_eth_payload_axis_tdata,
    output wire                  m_eth_payload_axis_tkeep,
    output wire                  m_eth_payload_axis_tvalid,
    input  wire                  m_eth_payload_axis_tready,
    output wire                  m_eth_payload_axis_tlast,
    output wire                  m_eth_payload_axis_tuser,

    /*
     * Transmit timestamp output
     */
    output wire [PTP_TS_WIDTH-1:0]    m_axis_tx_ptp_ts_96,
    output wire                       m_axis_tx_ptp_ts_valid,
    input  wire                       m_axis_tx_ptp_ts_ready,

    /*
     * Receive timestamp output
     */
    output wire [PTP_TS_WIDTH-1:0]    m_axis_rx_ptp_ts_96,
    output wire                       m_axis_rx_ptp_ts_valid,
    input  wire                       m_axis_rx_ptp_ts_ready,

    /*
     * PTP clock
     */
    output  wire [PTP_TS_WIDTH-1:0]    ptp_ts_96
);

// PHC parameters
parameter PTP_PERIOD_NS_WIDTH = 4;
parameter PTP_OFFSET_NS_WIDTH = 32;
parameter PTP_FNS_WIDTH = 32;
parameter PTP_PERIOD_NS = 4'd4;
parameter PTP_PERIOD_FNS = 32'd0;


// ptp clock
wire [95:0] ptp_ts_96;
wire ptp_ts_step;
wire output_pps;

reg ptp_perout_enable_reg = 1'b1;
wire ptp_perout_pulse;


reg valid_last = 0;
reg [7:0] led_reg = 0;


//assign led = sw;
// assign ledu = 0;
// assign ledl = 0;
// assign ledd = 0;
// assign ledr = 0;
// assign ledc = 0;
//assign led = led_reg;  //deactive leds which where before set during HW loopback
assign led[1] = ptp_perout_pulse;
assign phy_reset_n = !rst_125mhz;


eth_mac_1g_rgmii_fifo #(
    .TARGET(TARGET),
    .IODDR_STYLE("IODDR"),
    .CLOCK_INPUT_STYLE("BUFR"),
    .USE_CLK90("TRUE"),
    .ENABLE_PADDING(1),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_DEPTH(4096),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(4096),
    .RX_FRAME_FIFO(1),
    .LOGIC_PTP_PERIOD_NS(4'h6),
    .LOGIC_PTP_PERIOD_FNS(16'h6666),
    .PTP_PERIOD_NS(4'h6),
    .PTP_PERIOD_FNS(16'h6666),
    .PTP_USE_SAMPLE_CLOCK(0),
    .TX_PTP_TS_ENABLE(1),
    .RX_PTP_TS_ENABLE(1),
    .TX_PTP_TS_FIFO_DEPTH(64),
    .RX_PTP_TS_FIFO_DEPTH(64),
    .PTP_TS_WIDTH(96),
    .TX_PTP_TAG_ENABLE(0),
    .PTP_TAG_WIDTH(16)
)
eth_mac_inst (
    .gtx_clk(clk_125mhz),
    .gtx_clk90(clk90_125mhz),
    .gtx_rst(rst_125mhz),
    .logic_clk(clk_125mhz),
    .logic_rst(rst_125mhz),
    .ptp_sample_clk(clk_125mhz),

    .tx_axis_tdata(s_eth_payload_axis_tdata),
    .tx_axis_tvalid(s_eth_payload_axis_tvalid),
    .tx_axis_tready(s_eth_payload_axis_tready),
    .tx_axis_tlast(s_eth_payload_axis_tlast),
    .tx_axis_tuser(s_eth_payload_axis_tuser),

    .s_axis_tx_ptp_ts_tag(0),
    .s_axis_tx_ptp_ts_valid(0),
    .s_axis_tx_ptp_ts_ready(),

    .m_axis_tx_ptp_ts_96(m_axis_tx_ptp_ts_96),
    .m_axis_tx_ptp_ts_tag(),
    .m_axis_tx_ptp_ts_valid(m_axis_tx_ptp_ts_valid),
    .m_axis_tx_ptp_ts_ready(m_axis_tx_ptp_ts_ready),

    .rx_axis_tdata(m_eth_payload_axis_tdata),
    .rx_axis_tvalid(m_eth_payload_axis_tvalid),
    .rx_axis_tready(m_eth_payload_axis_tready),
    .rx_axis_tlast(m_eth_payload_axis_tlast),
    .rx_axis_tuser(m_eth_payload_axis_tuser),

    .m_axis_rx_ptp_ts_96(m_axis_rx_ptp_ts_96),
    .m_axis_rx_ptp_ts_valid(m_axis_rx_ptp_ts_valid),
    .m_axis_rx_ptp_ts_ready(m_axis_rx_ptp_ts_ready),

    .rgmii_rx_clk(phy_rx_clk),
    .rgmii_rxd(phy_rxd),
    .rgmii_rx_ctl(phy_rx_ctl),
    .rgmii_tx_clk(phy_tx_clk),
    .rgmii_txd(phy_txd),
    .rgmii_tx_ctl(phy_tx_ctl),

    .tx_fifo_overflow(),
    .tx_fifo_bad_frame(),
    .tx_fifo_good_frame(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .rx_fifo_overflow(),
    .rx_fifo_bad_frame(),
    .rx_fifo_good_frame(),
    .speed(),

    .ptp_ts_96(ptp_ts_96),

    .speed_sel(0),
    .aneg(1),
    .ifg_delay(12)
);


// PTP clock
ptp_clock #(
    .PERIOD_NS_WIDTH(PTP_PERIOD_NS_WIDTH),
    .OFFSET_NS_WIDTH(PTP_OFFSET_NS_WIDTH),
    .FNS_WIDTH(PTP_FNS_WIDTH),
    .PERIOD_NS(PTP_PERIOD_NS),
    .PERIOD_FNS(PTP_PERIOD_FNS),
    .DRIFT_ENABLE(0)
)
ptp_clock_inst (
    .clk(clk_250mhz),
    .rst(rst_250mhz),

    /*
     * Timestamp inputs for synchronization
     */
    .input_ts_96(0),
    .input_ts_96_valid(0),
    .input_ts_64(0),
    .input_ts_64_valid(1'b0),

    /*
     * Period adjustment
     */
    .input_period_ns(0),
    .input_period_fns(0),
    .input_period_valid(0),

    /*
     * Offset adjustment
     */
    .input_adj_ns(0),
    .input_adj_fns(0),
    .input_adj_count(0),
    .input_adj_valid(0),
    .input_adj_active(0),

    /*
     * Drift adjustment
     */
    .input_drift_ns(0),
    .input_drift_fns(0),
    .input_drift_rate(0),
    .input_drift_valid(0),

    /*
     * Timestamp outputs
     */
    .output_ts_96(ptp_ts_96),
    .output_ts_64(),
    .output_ts_step(ptp_ts_step),

    /*
     * PPS output
     */
    .output_pps(output_pps)
);


ptp_perout #(
    .FNS_ENABLE(0),
    .OUT_START_S(0),
    .OUT_START_NS(0),
    .OUT_START_FNS(0),
    .OUT_PERIOD_S(1),
    .OUT_PERIOD_NS(0),
    .OUT_PERIOD_FNS(0),
    .OUT_WIDTH_S(0),
    .OUT_WIDTH_NS(500000000),
    .OUT_WIDTH_FNS(0)
)
ptp_perout_inst (
    .clk(clk_250mhz),
    .rst(rst_250mhz),
    .input_ts_96(ptp_ts_96),
    .input_ts_step(ptp_ts_step),
    .enable(ptp_perout_enable_reg),
    .input_start(),
    .input_start_valid(),
    .input_period(),
    .input_period_valid(),
    .input_width(),
    .input_width_valid(),
    .locked(),
    .error(),
    .output_pulse(ptp_perout_pulse)
);

endmodule
