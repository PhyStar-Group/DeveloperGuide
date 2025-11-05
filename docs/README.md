# 如果只是查看文档，clone当前repo后，直接在本地用浏览器打开build/html/index.html

# Sphinx 启用流程

1. 如果有需要建立新的doc可以参考官网流程[https://www.sphinx-doc.org/zh_CN/master/tutorial/getting-started.html#setting-up-your-project-and-development-environment](https://www.sphinx-doc.org/zh_CN/master/tutorial/getting-started.html#setting-up-your-project-and-development-environment)
    目前的设置不需要建立新文档，此连接仅做参考。

2. 如果需要开发文档，可以按照以下流程配置
    - 我们通过虚拟环境变量的方式加载sphinx, 其中python需要3.x版本，如果系统默认python是连接2.x版本的话，可以把python 替换为python3
        ```
        python -m venv .venv
        python3 -m venv .venv // only if python is unavailable
        ```
        -  如果报如下错误，安装提示安装虚拟环境即可，sudo apt install python3.10-venv
            ```
            The virtual environment was not created successfully because ensurepip is not
            available.  On Debian/Ubuntu systems, you need to install the python3-venv
            package using the following command.

                apt install python3.10-venv

            You may need to use sudo with that command.  After installing the python3-venv
            package, recreate your virtual environment.
        ```
 
    - 加载虚拟环境
        ```
        source .venv/bin/activate
        ```
        如果后面想要卸载该虚拟环境，可以使用
        ```
        deactivate
        ```
        ```
        python -m pip install sphinx
        ```
        
        ```
        mkdir -p ~/.pip
        cat > ~/.pip/pip.conf << 'EOF'
        [global]
        index-url = https://pypi.tuna.tsinghua.edu.cn/simple
        timeout = 6000
        trusted-host = pypi.tuna.tsinghua.edu.cn
        EOF
        ```
    - 同时，本文档采用furo主题
        ```
        pip install furo
        ```
    - 为支持markdown
        ```
        pip install --upgrade myst_parser
        pip install --upgrade sphinx_markdown_tables
        ```
    - 为了方便环境配置，我写了一个自动配置的脚本，可运行以下命令自动配置
        ```bash
        source .venv/bin/activate
        pip install furo
        pip install --upgrade myst_parser
        pip install --upgrade sphinx_markdown_tables
        ```
    - 如何修改了文档，可以使用以下命令编译新的html
         ```bash
         make clean
         make html
         ```
         目前latex只支持纯英文，后续调研一下，看如何解决。
    - 以上启用操作需要在sphinxdoc目录中进行
    - 

