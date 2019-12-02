#for filter networking
/ip firewall filter
add action=add-src-to-address-list address-list=Syn_Flooder address-list-timeout=30m chain=input \
comment="Add Syn Flood IP to the list" connection-limit=30,32 disabled=no protocol=tcp tcp-flags=syn
add action=drop chain=input comment="Drop to syn flood list" disabled=no src-address-list=Syn_Flooder
add action=add-src-to-address-list address-list=Port_Scanner address-list-timeout=1w chain=input comment="Port Scanner Detect"\
disabled=no protocol=tcp psd=21,3s,3,1
add action=drop chain=input comment="Drop to port scan list" disabled=no src-address-list=Port_Scanner
add action=jump chain=input comment="Jump for icmp input flow" disabled=no jump-target=ICMP protocol=icmp
add action=drop chain=input\
comment="Block all access to the winbox - except to support list # DO NOT ENABLE THIS RULE BEFORE ADD YOUR SUBNET IN THE SUPPORT ADDRESS LIST"\
disabled=yes dst-port=8291 protocol=tcp src-address-list=!support
add action=jump chain=forward comment="Jump for icmp forward flow" disabled=no jump-target=ICMP protocol=icmp
add action=drop chain=forward comment="Drop to bogon list" disabled=no dst-address-list=bogons
add action=add-src-to-address-list address-list=spammers address-list-timeout=3h chain=forward comment="Add Spammers to the list for 3 hours"\
connection-limit=30,32 disabled=no dst-port=25,587 limit=30/1m,0 protocol=tcp
add action=drop chain=forward comment="Avoid spammers action" disabled=no dst-port=25,587 protocol=tcp src-address-list=spammers
add action=accept chain=input comment="Accept DNS - UDP" disabled=no port=53 protocol=udp
add action=accept chain=input comment="Accept DNS - TCP" disabled=no port=53 protocol=tcp
add action=accept chain=input comment="Accept to established connections" connection-state=established\ disabled=no
add action=accept chain=input comment="Accept to related connections" connection-state=related disabled=no
add action=accept chain=input comment="Full access to SUPPORT address list" disabled=no src-address-list=support
add action=drop chain=input comment="Drop anything else! # DO NOT ENABLE THIS RULE BEFORE YOU MAKE SURE ABOUT ALL ACCEPT RULES YOU NEED"\ disabled=yes
add action=accept chain=ICMP comment="Echo request - Avoiding Ping Flood" disabled=no icmp-options=8:0 limit=1,5 protocol=icmp
add action=accept chain=ICMP comment="Echo reply" disabled=no icmp-options=0:0 protocol=icmp
add action=accept chain=ICMP comment="Time Exceeded" disabled=no icmp-options=11:0 protocol=icmp
add action=accept chain=ICMP comment="Destination unreachable" disabled=no icmp-options=3:0-1 protocol=icmp
add action=accept chain=ICMP comment=PMTUD disabled=no icmp-options=3:4 protocol=icmp
add action=drop chain=ICMP comment="Drop to the other ICMPs" disabled=no protocol=icmp
add action=jump chain=output comment="Jump for icmp output" disabled=no jump-target=ICMP protocol=icmp
