# 实用工具

## Valgrind
Valgrind是一款轻量级的内存检测工具，可以非常方便地检测内存不安全问题，包括内存泄漏、空指针、使用未初始化的变量等等。

安装方式：
- 获取源码（版本号按需修改）：
    ```
    wget http://www.valgrind.org/downloads/valgrind-3.14.0.tar.bz2
    ```


- 解压缩：
    ```
    tar -jxvf valgrind-3.14.0.tar.bz2
    ```

- 配置安装（可通过`./configure --help`来查看各种选项）：
    ```
    ./configure
    ```

- 安装：
    ```
    make
    make install
    ```

- 使用：先用Debug模式编译可执行文件，例如`hit`。然后执行以下命令，便可检测内存泄漏问题
    ```
    valgrind --leak-check=yes --log-file=1_g ./hit
    ```

更多的使用方式请参考官网文档：
https://valgrind.org/docs/manual/quick-start.html