# 流场存储接口
目前仅支持笛卡尔网格下的MPI并行/串行的读写，可切换核数

## FluidCartRegularD<N_dim, FileTag>
笛卡尔网格下的双精度流体场读写接口类
- N_dim 为维度， 
- FileTag 为标签，默认为不存虚拟网格，大部分情况下不用管
- 推荐的API（具体参考源代码，或doxygen函数索引）

|函数名|说明|
| --- | --- | 
|SetMPI| 并行设置|
|SetMeshc<br>SetMeshf| 设置不同方向的网格，因为是笛卡尔，每个方向是一个一维数组，c代表网格中心位置，f代表网格面位置|
|SetGhostMesh| 设置虚拟网格数|
|SetDomain| 设置数据的流体域|
|SetFileAttr| 设置文件的属性|
| AllocateBuffer |申请缓存，共用的缓存区|
| DeallocateBuffer |释放缓存，共用的缓存区|
| Print |打印存储信息摘要|
|CreateFile |创建文件|
|OpenFile|打开存在的文件|
|CloseFile| 关闭文件|
|AddAttributeTo |添加属性到不同的FluidGroup|
|AddDataSetTo|添加数据集到不同的FluidGroup|
|AddDataSetCplxTo|添加复数数据集到不同的FluidGroup|
|AddField|添加场到Fields Group下|
|AddCplxField|添加复数场到Fields Group下|
|ReadAttributeFrom|从不同的FluidGroup读取属性|
|ReadDataSetFrom|从不同的FluidGroup读取数据|
|ReadDataSetCplxFrom|从不同的FluidGroup读取复数数据集|
|ReadField|从Fields Group读取场|
|ReadCplxField|从Fields Group读取复数场|

