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
    - CMAKE_INSTALL_PREFIX=/path/to/install （设置安装路径，绝对路径）
    - HDF5_BUILD_FORTRAN=ON
    - HDF5_ENABLE_PARALLEL=ON （注意：不要勾选c++版本）
5. 依次按下【c】,【g】
    ```
    make –j （-j后面的数字可根据计算机核数确定）
    ```
    - 如果安装在/opt等非用户目录下，需要管理员权限，需要在以上命令前均加sudo
6. 安装（将编译后的文件安装到/path/to/install）
    ```
    make install
    ```
7. 将/path/to/install添加至自己的环境变量

### openblas

1. 下载最新版本openblas[https://github.com/xianyi/OpenBLAS](https://github.com/xianyi/OpenBLAS)，并解压

2. 安装

   ```bash
   make -j
   make install PREFIX=/path/to/install
   ```

​	3. 并将安装路径加入到个人环境变量中

### FFTW3

1. 下载最新版本FFTW3 [https://fftw.org/](https://fftw.org/)

2. 解压（以fftw 3.3.10为例）

   ```bash
   tar -zxcf fftw-3.3.10.tar.gz
   cd fftw-3.3.10
   ```

3. 安装

   - 默认安装，将按照到/usr/local/bin

     ```bash
     ./configure
     make -j
     sudo make install
     ```

   - 如果要自定义安装路径

     ```bash
     ./configure --prefix=/path/to/install
     make -j
     sudo make install
     ```

   - 如果需要使用openmp，等其它编译选项，可以参见[https://www.fftw.org/fftw3_doc/Installation-on-Unix.html](https://www.fftw.org/fftw3_doc/Installation-on-Unix.html). 或者

     ```
     ./configure --help
     ```

4. 配置

   - 如果使用makefile编译项目

     ```	
     -I/path/to/install/include -L/path/to/install/lib -lfftw3 -lm
     ```

   - 如果使用cmake，由于很多cmake在自动查找fftw项目时容易出现问题，最好自己手动添加FFTW3_ROOT的路径
