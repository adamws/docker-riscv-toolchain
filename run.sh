#!/bin/bash

FTDI_USB_INFO=$(lsusb | grep "0403:6010")

if [ -z "$FTDI_USB_INFO" ]; then
	echo "FTDI device not found, running without debug support"
else
	FTDI_BUS=$(echo $FTDI_USB_INFO | sed 's/Bus \([0-9]*\).*/\1/')
	FTDI_DEVICE=$(echo $FTDI_USB_INFO | sed 's/.*Device \([0-9]*\).*/\1/')
fi

DOCKER_IMAGE=$1
shift 1
VOLUMES="$*"

docker run -it --rm --device /dev/bus/usb/${FTDI_BUS}/${FTDI_DEVICE} \
	--device /dev/ttyUSB1:/dev/ttyUSB1:rwm \
	${VOLUMES} \
	${DOCKER_IMAGE}
