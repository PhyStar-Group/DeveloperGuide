# 颗粒场的存储接口
目前支持MPI并行/串行颗粒，但暂不支持写入核与读取核不一致的情况

## PointParticleCartRegularD<N_dim>
- N_dim 维数
- 推荐API

|函数名|说明|
|---|---|
|CreateFile|创建文件|
|CloseFile|关闭文件|
|OpenFile|打开文件|
|AddPPField|添加颗粒场|
|ReadPPField|读取颗粒场|
