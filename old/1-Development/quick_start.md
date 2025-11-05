# 快速开始

## 准备工作

1. 安装需要的环境，见[环境配置](environment.md).

2. 假如以下软件被安装到以下目录

   hdf5:  /opt/hdf5/1.12.2

   openblas:  /opt/openblas

   fftw3: /opt/fftw3

   请在个人环境变量中添加

   ```shell
   export PATH=/opt/hdf5/1.12.2:/opt/openblas/:$PATH
   ```

   

## Example

以simpleflow为例

1. 下载PhyStar源码

2. 进入example/simpleflow目录， 并新建build目录

   ```shell
   cd example/simpleflow
   mkdir build
   ```

 3. 进入build目录，进行cmake

    ```shell
    cd build
    cmake -DFFTW3_ROOT=/path/of/FFTW3 ..
    ```

4. 编译

   ```shell
   make -j
   ```

 5. 将runscript_shear中所有文件，copy到build目录中

    ```shell
    cp -r ../runscript_shear/* .
    ```

6.  修改*.in 文件中的值

7. 运行

   核数根据实际情况选择

   ```shell
   mpirun -np 4 ./simpleflow3d
   ```

## 使用VSCode进行开发
通过VSCode可以更加方便地进行代码的管理、开发和测试。具体的使用技巧可以参考[利用VSCode进行开发](vscode_trick.md)

# 辅助文档
## Doxygen
为了方便开发者了解程序的结构以及相关类视图，我们利用Doxygen自动生成html形式的文档。具体操作如下：
1. Doxygen 安装(以ubuntu为例)
   ```shell
   sudo apt-get install doxygen
   ```
2. 进入doc/doxygen目录，生成html文件
   ```shell
   cd doc/doxygen
   doxygen ./Doxyfile
   ```
   将在doc/doxygen目录下生成html目录，用浏览器打开index.html即可
# Tests

需要googletest，后期再补充

# 常见问题
## mpi 编译器相关的异常
- 可能出现的问题：找不到mpi, 运行时报不知原因的“核数不匹配”的错误。
- 本程序目前仅支持gcc 和 openmpi, 暂不支持intel系列的编译器。请在编译相关代码时，选择合适的编译器。
- 如果使用vscode, 通过vim ~/.bashrc 注释intel系列环境，比如oneapi后，可能无法完全取消所有环境。此时，对于WSL用户，可以在左下角选择 Close Remote connection 重新连接进入。对于ssh用户，可shift+crtl+P, 输入kill VScode server on host 关闭远程的服务，以重置vscode 的环境。

