# 利用WSL开发的环境设置
## 大小写敏感
利用cmd或者powershell开启指定目录下的大小写敏感
```bash
fsutil.exe file setCaseSensitiveInfo D:\xxx\ enable
```
如果需要关闭，则将enable 改为disable
