#!/bin/sh

DIR="`dirname $0`"

AVRDUDE_EXE="$DIR/avrdude"
AVRDUDE_CONF="$DIR/avrdude.conf"
PORT="`echo /dev/tty.usbmodem*`"
HEX="$1"

if ! [ -f "$AVRDUDE_EXE" ]; then
    echo "avrdude executable $AVRDUDE_EXE not found"
    exit 1
elif ! [ -f "$AVRDUDE_CONF" ]; then
    echo "avrdude conf file $AVRDUDE_CONF not found"
    exit 1
elif ! [ -e "$PORT" ]; then
    echo "Port $PORT not found"
    exit 1
elif ! [ -f "$HEX" ]; then
    echo "File $HEX not found"
    exit 1
fi

"$AVRDUDE_EXE" -C "$AVRDUDE_CONF" -c wiring -p m2560 -P "$PORT" -b 115200 -U "flash:w:$HEX:i" -D
