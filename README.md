# WiFi_Detect_Mac
Wi-Fi infomation: SSID, signal, chanel, security...  
  
  

The project uses CoreWLAN and Airport to implement.

CoreWLAN cannot obtain the SECURITY type of Wi-Fi,

So, I call airport with NSTask to get information:

```
  SSID BSSID    RSSI CHANNEL HT CC SECURITY (auth/unicast/group)
  E504_5G       -87  153     Y  -- WPA(PSK/TKIP,AES/TKIP) 
  BBMG-JH       -84  6       Y  -- NONE
  RK_5GHz       -84  161     Y  -- WPA(PSK/TKIP,AES/TKIP)
```

![image](https://github.com/qianlishun/WiFi_Detect_Mac/blob/master/screenshot.png)
