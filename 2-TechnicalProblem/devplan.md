# 开发计划
## TOML

### TOML的简介(https://toml.io/en/)

### TOML的C++库
很多，非常轻量级，纯头文件（甚至只有单个文件），官方推荐的选择可查看[这里](https://github.com/toml-lang/toml/wiki)。

QJR：推荐tomlplusplus，因为支持C++17甚至20的特性。

[tomlplusplus](https://github.com/marzer/tomlplusplus)的引入方式有两种：

A: Drop toml.hpp wherever you like in your source tree (个人推荐)

B: Clone tomlplusplus repository, and then:
1. Add tomlplusplus/include to your include paths
2. #include <toml++/toml.h>

tomlplusplus的[使用示例](https://marzer.github.io/tomlplusplus/#mainpage-example-manipulations)

### 使用TOML来配置程序的初步示例
旧的config格式如下
```
#SET GLOBAL
    Case Name:      TGV
    Dimension:       3
    Start Step:     0               //step0, 开始步
    Step Number:    1000        //nstep, 从开始步计算NumStep步
    Start Time:      0.              //time0, 开始时间
    End Time:       -999.             //结束时间
    Dump Interval:  100             //step_ndump, 瞬时场存储步数间隔
    Dump Time:      -999.             //ndumptime, 瞬时场存储时间间隔
    Screen Interval: 100                //step_nscreen
    Statistic Interval: 100           //step_nstat
    Refresh Interval: 100             //step_nrefresh
    PP Solver Switch: 1
    Random Seed: 0 // seed < 0 时将使用系统时间作为seed，每个进程的真实seed=seed_0 + rankID
#ENDSET GLOBAL
```

改为toml后为

```
[Global] #中括号表示一个Table
CaseName=      "TGV"   # 字符串要用双引号
Dimension=       3     # 注释用井号
# 可利用.号来将同类的key组合
Step.Start=      0     #step0, 开始步   
Step.Number=    1000   #nstep, 从开始步计算NumStep步
Time.Start=      0.0   #time0, 开始时间，浮点数类型需要完整写出整个小数
# 0.或者.0是无效的
Time.End=       -999.0  #结束时间
Dump.Interval=  100     #step_ndump, 瞬时场存储步数间隔
Dump.Time=      -999.0  #ndumptime, 瞬时场存储时间间隔
Interval.Screen = 100   #step_nscreen   
Interval.Statistic = 100 #step_nstat
Interval.Refresh = 100   #step_nrefresh
PPSolver.Switch= 1
RandomSeed= 0          # seed < 0 时将使用系统时间作为seed
#每个进程的真实seed=seed_0 + rankID
```

toml还支持数组，例如
```
DomainSize = [[-1,1],[-1,1],[-3,3]]
```
更多使用方式还待进一步开发