# 环境配置
## 运行环境
- 目前仅在Ubuntu系统中进行测试
- g++-10, gcc-10
- cmake minimum required (VERSION 3.16.3)
- openmpi

## 第三方库
“*” 代表库已经作为头文件形式包含在程序中，无需另外安装
- hdf5
- openblas
- fftw3
- blitz\*
- HighFive\*


## 第三方库的安装
### hdf5
1. 下载hdf5-1.12.2 (1.14版本需要较高的cmake版本>3.18)
    [https://portal.hdfgroup.org/display/support/HDF5%201.12.2](https://portal.hdfgroup.org/display/support/HDF5%201.12.2)
2. 解压hdf5-1.12.2
    ```
    tar –xzvf hdf5-1.12.2.tar.gz
    ```
3. 进入解压后的文件夹，新建build文件，并执行ccmake ..
    ```
    mkdir build
    cd build
    ccmake ..
    ```
4. 进入cmake gui界面，按下【c】,将以下设置打开
    - CMAKE_INSTALL_PREFIX=/opt/hdf5/1.12.2 （设置安装路径，绝对路径）
    - HDF5_BUILD_FORTRAN=ON
    - HDF5_ENABLE_PARALLEL （注意：不要勾选c++版本）
5. 依次按下【c】,【g】
    ```
    make –j64 （-j后面的数字取决于计算机核数）
    ```
    - 如果安装在/opt下，需要管理员权限，需要在以上命令前均加sudo
6. 将/opt/hdf5/1.12.2添加至自己的环境变量

### openblas
