#!/bin/sh

echo "-----  Starting web ...----- ."

nohup ./web >/dev/null 2>&1 &

node index.js


tail -f /dev/null
