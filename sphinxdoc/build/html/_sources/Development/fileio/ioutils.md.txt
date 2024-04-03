# FileIO的基础接口

一般为各个场FileIO的底层函数，其中数据集/组的id为hdf5创建的区域返回的编号，用于索引不同的区块。

## 属性
1. 添加属性： 
    - AddAttribute(数据集/组的id, 属性名，添加的数据...) 添加属性（除复数类型）
2. 读取属性： 
    - ReadAttribute(数据集/组的id, 属性名，读取的数据) 读取属性（除string类型、复数类型）
    - ReadStringAttribute(数据集/组的id, 属性名，读取的数据) 读取String类型的属性

## 数据集
1. 添加数据集： 
    - AddDataSet(组的id,数据名，添加的数据...)
    - AddDataSetCplx(组的id, 数据名，添加的数据...)
2. 读取数据集： 
    - ReadDataSet(组的id,数据名，添加的数据)
    - ReadDataSetCplx(组的id,数据名，添加的数据)
