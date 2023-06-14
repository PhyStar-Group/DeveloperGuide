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

