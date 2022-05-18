# WiFi_Detect_Mac
Wi-Fi infomation: SSID, signal, chanel, security...  
  
使用 CoreWLAN 和 Airport 实现。  
CoreWLAN 无法获取到 Wi-Fi 的加密方式，
所以使用 NSTask 调用外部命令 airport 来获取 Wi-Fi 的加密方式。
  
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
