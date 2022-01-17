#300MHz Clock
set_property -dict {PACKAGE_PIN AC7 IOSTANDARD LVDS} [get_ports sys_clk_n]
set_property -dict {PACKAGE_PIN AC8 IOSTANDARD LVDS} [get_ports sys_clk_p]
create_clock -period 3.333 -name sys_clk_p [get_ports sys_clk_p]
create_clock -period 3.333 -name sys_clk_n [get_ports sys_clk_n]

#Reset Button
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS18} [get_ports reset]

#LEDs
set_property PACKAGE_PIN AG3 [get_ports {led[0]}];	# HP_DP_47_N
set_property PACKAGE_PIN AC14 [get_ports {led[1]}];	# HP_DP_20_P
set_property PACKAGE_PIN AD14 [get_ports {led[2]}];	# HP_DP_20_N
set_property PACKAGE_PIN AE14 [get_ports {led[3]}];	# HP_DP_21_P
set_property PACKAGE_PIN AE13 [get_ports {led[4]}];	# HP_DP_21_N
set_property PACKAGE_PIN AA14 [get_ports {led[5]}];	# HP_DP_22_P
set_property PACKAGE_PIN AB14 [get_ports {led[6]}];	# HP_DP_22_N
set_property PACKAGE_PIN AG4 [get_ports {led[7]}];	# HP_DP_47_P

set_property IOSTANDARD LVCMOS18 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[7]}]

#Ethernet PHY
set_property -dict {PACKAGE_PIN AE19 IOSTANDARD LVCMOS18} [get_ports {phy_reset_n}]

#set_property -dict { PACKAGE_PIN AD19 IOSTANDARD LVCMOS25 } [ get_ports phy_mdc ]
#set_property -dict { PACKAGE_PIN AC18 IOSTANDARD LVCMOS25 } [ get_ports phy_mdio ]

#RGMII Receive
set_property -dict {PACKAGE_PIN AF16 IOSTANDARD LVCMOS18} [get_ports phy_rx_clk]
set_property -dict {PACKAGE_PIN AG18 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[0]}]
set_property -dict {PACKAGE_PIN AH18 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[1]}]
set_property -dict {PACKAGE_PIN AE18 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[2]}]
set_property -dict {PACKAGE_PIN AF18 IOSTANDARD LVCMOS18} [get_ports {phy_rxd[3]}]
set_property -dict {PACKAGE_PIN AF17 IOSTANDARD LVCMOS18} [get_ports phy_rx_ctl]

#RGMII Transmit
set_property -dict {PACKAGE_PIN AJ17 IOSTANDARD LVCMOS18} [get_ports phy_tx_clk]
set_property -dict {PACKAGE_PIN AH17 IOSTANDARD LVCMOS18} [get_ports {phy_txd[0]}]
set_property -dict {PACKAGE_PIN AJ16 IOSTANDARD LVCMOS18} [get_ports {phy_txd[1]}]
set_property -dict {PACKAGE_PIN AK16 IOSTANDARD LVCMOS18} [get_ports {phy_txd[2]}]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS18} [get_ports {phy_txd[3]}]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS18} [get_ports phy_tx_ctl]

# PHY generates 125MHz clock
create_clock -period 8.000 -name phy_rx_clk -waveform {0.000 4.000} [get_ports phy_rx_clk]

# UART
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports uart_txd]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports uart_rxd]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports uart_rts]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports uart_cts]
