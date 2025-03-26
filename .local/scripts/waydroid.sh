#!/usr/bin/env bash
waydroid prop set persist.waydroid.width 360
waydroid prop set persist.waydroid.height 720

sudo sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' \
     /usr/lib/waydroid/data/scripts/waydroid-net.sh
sudo systemctl restart waydroid-container.service 
