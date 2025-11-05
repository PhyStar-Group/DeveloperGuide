# 利用VSCode进行开发

## VSCode必备插件
### C/C++
C/C++基础插件。提供语法高亮，Intellisense等基础功能。
>Description: C/C++ IntelliSense, debugging, and code browsing.

>VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools

### CMake Tools
用于在VSCode中方便地执行Cmake设置，快捷切换编译模式、编译目标，自定义编译选项。

>Description: Extended CMake support in Visual Studio Code

>VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools

### 远程开发插件Remote - SSH
用于远程连接linux服务器开发。源代码、编译、编译产生的文件均位于服务器，便于调试和测试环境。
>Description: Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.

>VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh


## 开始使用VSCode开发PhyStar

### 首次打开
1. 使用远程插件或直接打开PhyStar顶层文件夹。
2. 确认所有必备插件已开启。
3. VSCode将自动弹出输入框，选择你想要编译的CMakeLists.txt文件，例如`PhyStar/example/simpleflow/CMakeLists.txt`。如果错过了输入框，可以按Ctrl+Shift+P，输入`CMake: Configure`重新进行操作。
4. 此时有可能遇到错误`vscode [ctest] Folder is not found in Test Explorer`，按Ctrl+Shift+P，`reload window`即可顺利进行初次Configure。
5. 按Ctrl+Shift+P，打开VSCode设置栏，查找`settings.json`，选择`Workspace`范围的JSON，加入以下的设置
````
    "cmake.configureArgs": [
        "-DFFTW3_ROOT=/opt/fftw3/"
    ],// 设置CMake configure时的fftw3目录
````


6. 若Intenllisense无法正常工作，在`settings.json`中加入下面的设置
````
"C_Cpp.default.compileCommands": "${config:cmake.buildDirectory}/compile_commands.json", // 设置intellisense的包含范围
````
7. 在VSCode下方工具栏找到CMake选项，将编译选项设置为Release。选择CMake编译器，和你实际使用的编译器一致。

8. 此时，Intellisense应该能够准确识别和检测代码中的语法和错误，开始愉快的开发之旅吧！

### 使用技巧
由于PhyStar的项目结构存在多个编译目标（多个可用于编译的CMakeLists.txt），可以修改`settings.json`中的`cmake.sourceDirectory`选项来指定你想要编译的目标目录。修改目录后需要reload避免奇怪的bug。







