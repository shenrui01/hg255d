#
# Copyright (C) 2012 OpenWrt-DreamBox
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/WAP120NF
	NAME:=WAP120NF Profile
	PACKAGES:=kmod-leds-gpio kmod-rt2880-pci wpad-mini kmod-usb-rt305x-dwc_otg
endef

define Profile/WAP120NF/Description
	WAP120NF package set compatible with most boards.
endef
$(eval $(call Profile,WAP120NF))
