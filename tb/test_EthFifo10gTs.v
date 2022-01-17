/*
Copyright (c) 2015-2019 Alex Forencich
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

`timescale 1ps / 1fs

/*
 * Testbench for 10G ETH MAC incl. ptp_clock (Timestamps)
 * PHY XGMII Interface in Loopback
 */
module test_EthFifo10gTs;

// Parameters for PTP clock
parameter PERIOD_NS_WIDTH = 4;
parameter OFFSET_NS_WIDTH = 4;
parameter DRIFT_NS_WIDTH = 4;
parameter FNS_WIDTH = 16;
parameter PERIOD_NS = 4'h6;
parameter PERIOD_FNS = 16'h6666;
parameter DRIFT_ENABLE = 1;
parameter DRIFT_NS = 4'h0;
parameter DRIFT_FNS = 16'h0002;
parameter DRIFT_RATE = 16'h0005;

// Inputs for PTP clock
reg clk_250MHz = 0;
reg rst = 0;


reg [7:0] current_test = 0;
reg [95:0] input_ts_96 = 0;
reg input_ts_96_valid = 0;
reg [63:0] input_ts_64 = 0;
reg input_ts_64_valid = 0;
reg [PERIOD_NS_WIDTH-1:0] input_period_ns = 0;
reg [FNS_WIDTH-1:0] input_period_fns = 0;
reg input_period_valid = 0;
reg [OFFSET_NS_WIDTH-1:0] input_adj_ns = 0;
reg [FNS_WIDTH-1:0] input_adj_fns = 0;
reg [15:0] input_adj_count = 0;
reg input_adj_valid = 0;
reg [DRIFT_NS_WIDTH-1:0] input_drift_ns = 0;
reg [FNS_WIDTH-1:0] input_drift_fns = 0;
reg [15:0] input_drift_rate = 0;
reg input_drift_valid = 0;
// Outputs for PTP clock
wire input_adj_active;
wire [95:0] output_ts_96;
wire [63:0] output_ts_64;
wire output_ts_step;
wire output_pps;

// Parameters for eth mac 10g fifo
parameter DATA_WIDTH = 64;
parameter CTRL_WIDTH = (DATA_WIDTH/8);
parameter AXIS_DATA_WIDTH = DATA_WIDTH;
parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8);
parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8);
parameter ENABLE_PADDING = 1;
parameter ENABLE_DIC = 1;
parameter MIN_FRAME_LENGTH = 64;
parameter TX_FIFO_DEPTH = 4096;
parameter TX_FRAME_FIFO = 1;
parameter TX_DROP_BAD_FRAME = TX_FRAME_FIFO;
parameter TX_DROP_WHEN_FULL = 0;
parameter RX_FIFO_DEPTH = 4096;
parameter RX_FRAME_FIFO = 1;
parameter RX_DROP_BAD_FRAME = RX_FRAME_FIFO;
parameter RX_DROP_WHEN_FULL = RX_FRAME_FIFO;
parameter LOGIC_PTP_PERIOD_NS = 4'h6;
parameter LOGIC_PTP_PERIOD_FNS = 16'h6666;
parameter PTP_PERIOD_NS = 4'h6;
parameter PTP_PERIOD_FNS = 16'h6666;
parameter PTP_USE_SAMPLE_CLOCK = 0;
parameter TX_PTP_TS_ENABLE = 1;
parameter RX_PTP_TS_ENABLE = 1;
parameter TX_PTP_TS_FIFO_DEPTH = 64;
parameter RX_PTP_TS_FIFO_DEPTH = 64;
parameter PTP_TS_WIDTH = 96;
parameter TX_PTP_TAG_ENABLE = 0;
parameter PTP_TAG_WIDTH = 16;

// Clocks and Resets for the 10G ETH MAC
reg clk_156MHz = 0;
reg sfp_1_tx_clk = 0;
reg sfp_1_rx_clk = 0;

reg sfp_1_rx_rst = 0;
reg sfg_1_tx_rst = 0;

// Inputs for eth mac 10g fifo
wire [AXIS_DATA_WIDTH-1:0] tx_axis_tdata;
wire [AXIS_KEEP_WIDTH-1:0] tx_axis_tkeep;
wire tx_axis_tvalid;
wire tx_axis_tlast;
wire tx_axis_tuser;
//reg rx_axis_tready;
wire rx_axis_tready;

wire [DATA_WIDTH-1:0] sfp_1_rxd;
wire [CTRL_WIDTH-1:0] sfp_1_rxc;

// Outputs for eth mac 10g fifo
wire [AXIS_DATA_WIDTH-1:0] rx_axis_tdata;
wire [AXIS_KEEP_WIDTH-1:0] rx_axis_tkeep;
wire rx_axis_tvalid;
wire rx_axis_tlast;
wire rx_axis_tuser;
wire tx_axis_tready;
//reg m_axis_tready = 0;

// Configuration
//reg ifg_delay = 8'd12;

wire tx_error_underflow;
wire tx_fifo_overflow;
wire tx_fifo_bad_frame;
wire tx_fifo_good_frame;
wire rx_error_bad_frame;
wire rx_error_bad_fcs;
wire rx_fifo_overflow;
wire rx_fifo_bad_frame;
wire rx_fifo_good_frame;
wire ptp_sample_clock;

// Inputs for axis tx fifo
//reg s_eth_hdr_ready = 0;
reg s_eth_hdr_valid = 0;
reg [47:0] s_eth_dest_mac = 0;
reg [47:0] s_eth_src_mac = 0;
reg [15:0] s_eth_type = 0;
reg [AXIS_DATA_WIDTH-1:0] s_eth_payload_axis_tdata = 0;
reg [AXIS_KEEP_WIDTH-1:0] s_eth_payload_axis_tkeep = 0;
reg s_eth_payload_axis_tvalid = 0;
reg s_eth_payload_axis_tlast = 0;
reg s_eth_payload_axis_tuser = 0;
//reg m_axis_tready = 0;
wire tx_fifo_busy;

// Outputs for axis rx fifo
wire m_eth_hdr_ready;
wire m_eth_hdr_valid;
wire [47:0] m_eth_dest_mac;
wire [47:0] m_eth_src_mac;
wire [15:0] m_eth_type;
wire [AXIS_DATA_WIDTH-1:0] m_eth_payload_axis_tdata;
wire [AXIS_KEEP_WIDTH-1:0] m_eth_payload_axis_tkeep;
wire m_eth_payload_axis_tvalid;
wire m_eth_payload_axis_tlast;
wire m_eth_payload_axis_tuser;
wire m_eth_payload_axis_tready;
wire rx_fifo_busy;
wire error_header_early_termination;

wire [95:0] tx_ts;

// duration for each bit = 20 * timescale = 2 * 1 ns  = 2ns
localparam period = 2000;  

ptp_clock #(
    .PERIOD_NS_WIDTH(PERIOD_NS_WIDTH),
    .OFFSET_NS_WIDTH(OFFSET_NS_WIDTH),
    .DRIFT_NS_WIDTH (DRIFT_NS_WIDTH),
    .FNS_WIDTH(FNS_WIDTH),
    .PERIOD_NS(PERIOD_NS),
    .PERIOD_FNS(PERIOD_FNS),
    .DRIFT_ENABLE(DRIFT_ENABLE),
    .DRIFT_NS(DRIFT_NS),
    .DRIFT_FNS(DRIFT_FNS),
    .DRIFT_RATE(DRIFT_RATE)
)
UUT_ptp_clock (
    .clk(clk_250MHz),
    .rst(rst),
    .input_ts_96(input_ts_96),
    .input_ts_96_valid(input_ts_96_valid),
    .input_ts_64(input_ts_64),
    .input_ts_64_valid(input_ts_64_valid),
    .input_period_ns(input_period_ns),
    .input_period_fns(input_period_fns),
    .input_period_valid(input_period_valid),
    .input_adj_ns(input_adj_ns),
    .input_adj_fns(input_adj_fns),
    .input_adj_count(input_adj_count),
    .input_adj_valid(input_adj_valid),
    .input_adj_active(input_adj_active),
    .input_drift_ns(input_drift_ns),
    .input_drift_fns(input_drift_fns),
    .input_drift_rate(input_drift_rate),
    .input_drift_valid(input_drift_valid),
    .output_ts_96(output_ts_96),
    .output_ts_64(output_ts_64),
    .output_ts_step(output_ts_step),
    .output_pps(output_pps)
);

eth_mac_10g_fifo #(
	.DATA_WIDTH(DATA_WIDTH),
    .ENABLE_PADDING(1),
    .ENABLE_DIC(1),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH),
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
UUT_eth_mac_10g_fifo (
    .rx_clk(sfp_1_rx_clk),
    .rx_rst(sfp_1_rx_rst),
    .tx_clk(sfp_1_tx_clk),
    .tx_rst(sfg_1_tx_rst),
    .logic_clk(clk_156MHz),
    .logic_rst(rst),
	/* 
	 * AXI IN
	 */ 
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    
    .s_axis_tx_ptp_ts_tag(),
    .s_axis_tx_ptp_ts_valid(),
    .s_axis_tx_ptp_ts_ready(),

    .m_axis_tx_ptp_ts_96(tx_ts),
    .m_axis_tx_ptp_ts_tag(),
    .m_axis_tx_ptp_ts_valid(),
    .m_axis_tx_ptp_ts_ready(1),

	/* 
	 * AXI OUT
	 */ 
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    .m_axis_rx_ptp_ts_96(),
    .m_axis_rx_ptp_ts_valid(),
    .m_axis_rx_ptp_ts_ready(1),

	/* 
	 * XGMII Interface (Loopback enabled)
	 */ 
    .xgmii_rxd(sfp_1_rxd),
    .xgmii_rxc(sfp_1_rxc),
    .xgmii_txd(sfp_1_rxd),
    .xgmii_txc(sfp_1_rxc),
	/*
	 * Status
	 */ 
    .tx_fifo_overflow(tx_fifo_overflow),
    .tx_fifo_bad_frame(tx_fifo_bad_frame),
    .tx_fifo_good_frame(tx_fifo_good_frame),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .rx_fifo_overflow(rx_fifo_overflow),
    .rx_fifo_bad_frame(rx_fifo_bad_frame),
    .rx_fifo_good_frame(rx_fifo_good_frame),

    .ptp_ts_96(output_ts_96),

	/*
	 * Configuration
	 */ 
    .ifg_delay(8'd12)
);

eth_axis_tx #(
    .DATA_WIDTH(AXIS_DATA_WIDTH)
)
UUT_eth_axis_tx (
    .clk(clk_156MHz),
    .rst(rst),
	/*
	 * ETH IN
	 */ 
    .s_eth_hdr_valid(s_eth_hdr_valid),
    .s_eth_hdr_ready(s_eth_hdr_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_eth_payload_axis_tdata(s_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(s_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(s_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(s_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(s_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(s_eth_payload_axis_tuser),
	/*
	 * AXI OUT
	 */
    .m_axis_tdata(tx_axis_tdata),
    .m_axis_tkeep(tx_axis_tkeep),
    .m_axis_tvalid(tx_axis_tvalid),
    .m_axis_tready(tx_axis_tready),
    .m_axis_tlast(tx_axis_tlast),
    .m_axis_tuser(tx_axis_tuser),
	/*
	 * Status
	 */ 
    .busy(tx_fifo_busy)
);

eth_axis_rx #(
    .DATA_WIDTH(AXIS_DATA_WIDTH)
)
UUT_eth_axis_rx (
    .clk(clk_156MHz),
    .rst(rst),
	/*
	 * AXI IN
	 */
	.s_axis_tdata(rx_axis_tdata),
    .s_axis_tkeep(rx_axis_tkeep),
    .s_axis_tvalid(rx_axis_tvalid),
    .s_axis_tready(rx_axis_tready),
    .s_axis_tlast(rx_axis_tlast),
    .s_axis_tuser(rx_axis_tuser),
	/*
	 * ETH OUT
	 */
    .m_eth_hdr_valid(m_eth_hdr_valid),
    .m_eth_hdr_ready(1),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(m_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(1),
    .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),
	/*
	 * Status
	 */ 
    .busy(rx_fifo_busy),
	.error_header_early_termination(error_header_early_termination)
);

// note that sensitive list is omitted in always block
// therefore always-block run forever
// clock period = 2 ns
always 
begin
    clk_250MHz = 1'b1; 
    #2000; // high for 20 * timescale = 2 ns

    clk_250MHz = 1'b0;
    #2000; // low for 20 * timescale = 2 ns
end

// note that sensitive list is omitted in always block
// therefore always-block run forever
// clock period = 2 ns
always 
begin
    clk_156MHz = 1'b1; 
	sfp_1_rx_clk = 1'b1;
	sfp_1_tx_clk = 1'b1;
    #3200; // high for 32 * timescale = 2 ns

    clk_156MHz = 1'b0;
	sfp_1_rx_clk = 1'b0;
	sfp_1_tx_clk = 1'b0;
    #3200; // low for 32 * timescale = 2 ns
end

integer i, j, count;

initial 
    begin
    
    rst = 1'b1;
	sfp_1_rx_rst = 1'b1;
	sfg_1_tx_rst = 1'b1;
    #3200;
	
    rst = 1'b0;
	sfp_1_rx_rst = 1'b0;
	sfg_1_tx_rst = 1'b0;

    #48000;
    #15000;
	
    //#15000;
// ---------------------------------------------------------------------- Send first eth frame ----------------------------------------------------------------------
//	Field                       Length
//	Destination MAC address     6 octets
//	Source MAC address          6 octets
//	Ethertype (0x0800)          2 octets
    s_eth_dest_mac = 48'h200000000000;
    s_eth_src_mac =  48'hf00000000000;
    s_eth_type = 16'h0800;
	
    s_eth_hdr_valid = 1;
    s_eth_payload_axis_tvalid = 1;
    s_eth_payload_axis_tlast = 0;
	//rx_axis_tready = 0;

    //#32000;
	
	s_eth_payload_axis_tdata = { 16'hABCD, 16'h0000, 16'hFFFF, 16'h1111 };
	s_eth_payload_axis_tkeep = 8'b11110111;
	
	#32000;
	
	//s_eth_payload_axis_tkeep = 8'b11110101;
	
	for (i=0; i<DATA_WIDTH-1; i=i+1) begin
		s_eth_payload_axis_tdata[i] = i;
        #3200;
    end

	#32000;
	
	s_eth_payload_axis_tvalid = 1;
	s_eth_payload_axis_tlast = 1;
	
	#6400;
	
	s_eth_payload_axis_tvalid = 0;
	s_eth_payload_axis_tlast = 0;
	s_eth_hdr_valid = 0;
	//rx_axis_tready = 1;
	
	//#6400;

// ---------------------------------------------------------------------- First eth frame sent ----------------------------------------------------------------------
    #1000000;
// ---------------------------------------------------------------------- Send second eth frame with padding --------------------------------------------------------
    s_eth_dest_mac = 48'h200000000000;
    s_eth_src_mac =  48'hf00000000000;
    s_eth_type = 16'h0800;
    s_eth_hdr_valid = 1;
    s_eth_payload_axis_tvalid = 1;
    s_eth_payload_axis_tlast = 0;
	
	s_eth_payload_axis_tkeep = 4'b0001;
    #8000;
    for (i=120; i>15; i=i-5) begin
        s_eth_payload_axis_tdata = i;
		//s_eth_payload_axis_tkeep = i;
        #8000;
    end
    s_eth_payload_axis_tdata = 4'b1111;
	s_eth_payload_axis_tkeep = 4'b1111;
    s_eth_payload_axis_tvalid = 1;
    s_eth_payload_axis_tlast = 1;
    #8000;
    s_eth_payload_axis_tdata = 4'b0000;
	s_eth_payload_axis_tkeep = 4'b0000;
    s_eth_payload_axis_tvalid = 0;
    s_eth_payload_axis_tlast = 0;
    s_eth_hdr_valid = 0;

// ---------------------------------------------------------------------- Second eth frame sent --------------------------------------------------------------------
end
endmodule