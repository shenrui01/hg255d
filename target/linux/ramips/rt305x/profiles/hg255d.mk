#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/HG255D
	NAME:=HG255D Profile
	PACKAGES:=kmod-leds-gpio kmod-rt2880-pci wpad-mini kmod-usb-rt305x-dwc_otg
endef

define Profile/HG255D/Description
	HG255D package set compatible with most boards.
endef
$(eval $(call Profile,HG255D))
