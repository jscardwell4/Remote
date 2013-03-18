#!/usr/bin/awk -f

#  PruneCodeDatabase.sh
#  Remote
#
#  Created by Jason Cardwell on 9/8/12.
#  Copyright (c) 2012 Moondeer Studios. All rights reserved.
BEGIN {
contentToPrint = ""
inDict = 0
addDict = 1
checkManufacturer = 0
}

/		<dict>/ {
inDict = 1
contentToPrint = contentToPrint "\n" $0
next
}

(inDict == 0) {
contentToPrint = contentToPrint "\n" $0
next
}

(inDict == 1) && /			<key>Manufacturer/ {
checkManufacturer = 1
contentToPrint = contentToPrint "\n" $0
next
}

(checkManufacturer == 1) && /			<string>/ {
man = $0
sub(/<string>/,"",man);
sub(/<\/string>/,"",man);
if (man ~ /Philips|Toshiba|Sony|Apple|LG|Yamaha/) {
    addDict = 1
} else {
	addDict = 0
}
contentToPrint = contentToPrint "\n" $0
checkManufacturer = 0
next
}

/		<\/dict/ {
inDict = 0
contentToPrint = contentToPrint "\n" $0
if (addDict == 1) {
print contentToPrint
}
contentToPrint = ""
next
}

(inDict == 1) {
contentToPrint = contentToPrint "\n" $0
}

END {
print contentToPrint
}
