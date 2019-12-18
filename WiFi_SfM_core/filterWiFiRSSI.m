function [wifiScanRSSI] = filterWiFiRSSI(wifiScanRSSI, minRSSIValue)


% filter out weak RSSI value
for k = 1:size(wifiScanRSSI,2)
    weakRSSIIndex = (wifiScanRSSI(k).RSSI < minRSSIValue);
    wifiScanRSSI(k).RSSI(weakRSSIIndex) = -200;
end


end

