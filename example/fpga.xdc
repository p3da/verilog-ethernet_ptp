#250MHz Clock
set_property -dict {PACKAGE_PIN H22 IOSTANDARD DIFF_SSTL15} [get_ports sys_clk_p]
set_property -dict {PACKAGE_PIN H23 IOSTANDARD DIFF_SSTL15} [get_ports sys_clk_n]
create_clock -period 4.000 -name sys_clk_p [get_ports sys_clk_p]
create_clock -period 4.000 -name sys_clk_n [get_ports sys_clk_n]

#LEDs
set_property -dict {LOC D16 IOSTANDARD LVCMOS18} [get_ports {led[0]}]
set_property -dict {LOC G16 IOSTANDARD LVCMOS18} [get_ports {led[1]}]
set_property -dict {LOC H16 IOSTANDARD LVCMOS18} [get_ports {led[2]}]
set_property -dict {LOC E18 IOSTANDARD LVCMOS18} [get_ports {led[3]}]
set_property -dict {LOC E17 IOSTANDARD LVCMOS18} [get_ports {led[4]}]
set_property -dict {LOC E16 IOSTANDARD LVCMOS18} [get_ports {led[5]}]
set_property -dict {LOC H18 IOSTANDARD LVCMOS18} [get_ports {led[6]}]
set_property -dict {LOC H17 IOSTANDARD LVCMOS18} [get_ports {led[7]}]

#Reset Button 
set_property -dict {LOC K18 IOSTANDARD LVCMOS15} [get_ports reset]

#Toggle Switches
set_property -dict {LOC G20 IOSTANDARD LVCMOS15} [get_ports {sw[0]}]
set_property -dict {LOC H19 IOSTANDARD LVCMOS15} [get_ports {sw[1]}]
set_property -dict {LOC K22 IOSTANDARD LVCMOS15} [get_ports {sw[2]}]
set_property -dict {LOC L22 IOSTANDARD LVCMOS15} [get_ports {sw[3]}]
set_property -dict {LOC G22 IOSTANDARD LVCMOS15} [get_ports {sw[4]}]
set_property -dict {LOC G21 IOSTANDARD LVCMOS15} [get_ports {sw[5]}]
set_property -dict {LOC H21 IOSTANDARD LVCMOS15} [get_ports {sw[6]}]
set_property -dict {LOC J21 IOSTANDARD LVCMOS15} [get_ports {sw[7]}]

#Ethernet PHY

#Interupt and Reset
#set_property -dict { LOC AH14 IOSTANDARD LVCMOS25 } [ get_ports phy_int_n ]
set_property -dict {LOC D9 IOSTANDARD LVCMOS18} [get_ports phy_reset_n]
#set_property -dict { LOC C9 IOSTANDARD LVCMOS25 } [ get_ports phy_mdc ]
#set_property -dict { LOC C8 IOSTANDARD LVCMOS25 } [ get_ports phy_mdio ]

#RGMII Transmit
set_property -dict {LOC G10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports phy_tx_clk]
#set_property -dict { LOC AD12 IOSTANDARD LVCMOS25 } [ get_ports phy_tx_clk ]
set_property -dict {LOC H8 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {phy_txd[0]}]
set_property -dict {LOC H9 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {phy_txd[1]}]
set_property -dict {LOC J9 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {phy_txd[2]}]
set_property -dict {LOC J10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {phy_txd[3]}]
#set_property -dict { LOC AL10 IOSTANDARD LVCMOS25 SLEW FAST } [ get_ports { phy_txd[4] } ]
#set_property -dict { LOC AM10 IOSTANDARD LVCMOS25 SLEW FAST } [ get_ports { phy_txd[5] } ]
#set_property -dict { LOC AE11 IOSTANDARD LVCMOS25 SLEW FAST } [ get_ports { phy_txd[6] } ]
#set_property -dict { LOC AF11 IOSTANDARD LVCMOS25 SLEW FAST } [ get_ports { phy_txd[7] } ]
set_property -dict {LOC G9 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports phy_tx_ctl]
#set_property -dict { LOC AH10 IOSTANDARD LVCMOS25 SLEW FAST } [ get_ports { phy_tx_er } ]

#RGMII Receive
set_property -dict {LOC E11 IOSTANDARD LVCMOS18} [get_ports phy_rx_clk]
set_property -dict {LOC A10 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[0]}]
set_property -dict {LOC B10 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[1]}]
set_property -dict {LOC B11 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[2]}]
set_property -dict {LOC C11 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[3]}]
#set_property -dict { LOC AM12 IOSTANDARD LVCMOS25 } [ get_ports { phy_rxd[4] } ]
#set_property -dict { LOC AD11 IOSTANDARD LVCMOS25 } [ get_ports { phy_rxd[5] } ]
#set_property -dict { LOC AC12 IOSTANDARD LVCMOS25 } [ get_ports { phy_rxd[6] } ]
#set_property -dict { LOC AC13 IOSTANDARD LVCMOS25 } [ get_ports { phy_rxd[7] } ]
set_property -dict {LOC D11 IOSTANDARD LVCMOS18} [get_ports phy_rx_ctl]
#set_property -dict { LOC AG12 IOSTANDARD LVCMOS25 } [ get_ports phy_rx_er ]

create_clock -period 8.000 -name phy_rx_clk -waveform {0.000 4.000} [get_ports phy_rx_clk]

#unused but have to be defined
#Toggle Switches
set_property -dict {LOC G20 IOSTANDARD LVCMOS15} [get_ports {sw[0]}]
set_property -dict {LOC H19 IOSTANDARD LVCMOS15} [get_ports {sw[1]}]
set_property -dict {LOC K22 IOSTANDARD LVCMOS15} [get_ports {sw[2]}]
set_property -dict {LOC L22 IOSTANDARD LVCMOS15} [get_ports {sw[3]}]
set_property -dict {LOC G22 IOSTANDARD LVCMOS15} [get_ports {sw[4]}]
set_property -dict {LOC G21 IOSTANDARD LVCMOS15} [get_ports {sw[5]}]
set_property -dict {LOC H21 IOSTANDARD LVCMOS15} [get_ports {sw[6]}]
set_property -dict {LOC J21 IOSTANDARD LVCMOS15} [get_ports {sw[7]}]
#other unused pins
set_property -dict {LOC C19 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC D20 IOSTANDARD LVCMOS18} [get_ports uart_txd]
set_property -dict {LOC L18 IOSTANDARD LVCMOS15} [get_ports btnu]
set_property -dict {LOC K21 IOSTANDARD LVCMOS15} [get_ports btnl]
set_property -dict {LOC K20 IOSTANDARD LVCMOS15} [get_ports btnd]
set_property -dict { LOC J13 IOSTANDARD LVCMOS18} [get_ports btnc]
set_property -dict { LOC H13 IOSTANDARD LVCMOS18} [get_ports btnr]
set_property -dict { LOC A13 IOSTANDARD LVCMOS18} [get_ports ledc]
set_property -dict { LOC A12 IOSTANDARD LVCMOS18} [get_ports ledd]
set_property -dict { LOC C12 IOSTANDARD LVCMOS18} [get_ports ledl]
set_property -dict { LOC B12 IOSTANDARD LVCMOS18} [get_ports ledr]
set_property -dict { LOC D13 IOSTANDARD LVCMOS18} [get_ports ledu]
set_property -dict { LOC C13 IOSTANDARD LVCMOS18} [get_ports uart_cts]
set_property -dict { LOC F9 IOSTANDARD LVCMOS18} [get_ports uart_rts]
