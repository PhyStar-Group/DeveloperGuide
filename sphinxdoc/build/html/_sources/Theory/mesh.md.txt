# 笛卡尔网格类
## CartMeshComp.h
生成一维网格分量
### 拉伸网格表达式
变量：$L$长度， $y_i=iL/N$,其中N为网格数，不包括虚拟网格
1. $L[\frac{1}{2}\frac{\arctan[s(y_i-L/2)]}{\arctan(s L/2)}+\frac{1}{2}]$
2. $L[\frac{1}{2}\frac{\tanh[s(y_i-L/2)]}{\tanh(s L/2)}+\frac{1}{2}]$
3. $L[\frac{1}{2}\frac{\sin[s\pi/2(y_i-L/2)]}{\sin(s \pi/2)}+\frac{1}{2}]$
