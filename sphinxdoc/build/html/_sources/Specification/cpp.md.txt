# PhyStar程序规范

## 规范制定人

崔智文    2022/06/13    


## C++程序标准

- C++ 标准：为了长远考虑，尽可能以c++-20标准作为基础。由于历史代码的兼容性，代码书写不要超过c++-20的标准范围
- 一些推荐的特性：(后期补充)
- **以下内容仅为约定，具体内容将随PhyStar的开发进行更改**

## 基本数据类型

### 别名

- 浮点数：统一用"Real" 代替浮点数，在头文件添加，利用相关宏命令进行区分

```c++
#ifdef D_FLOAT
using Real = float; //对应fortran kind =4 
#else
using Real = double;//对应fortran kind =8
#endif
```

- 整型：(暂定)

  ```c++
  using Int = int; //对应fortran kind =4
  using Intl = long long; //对应fortran kind =8
  using uInt = unsigned int;
  using uIntl = unsigned long long;
  ```
  
- 复数

```c++
using Complex = std::complex<Real>;//单双精度由Real 决定
```

- 使用其他开源软件中，未被允许的基本数据类型别名，需要在使用前用注释说明别名定义

### 常量

- 数学常量：全部大写，
  
    - 可使用c++/c 标准自带的，cmath 或math.h， 需要在#include前定义宏变量#define _USE_MATH_DEFINES
    
    ```
    #define _USE_MATH_DEFINES // for C++
    #include <cmath>
    
  #define _USE_MATH_DEFINES // for C
  #include <math.h>
  ```
  | 符号         | 表达式     | 值                      |
  | :----------- | :--------- | :---------------------- |
  | `M_E`        | e          | 2.71828182845904523536  |
  | `M_LOG2E`    | log2(e)    | 1.44269504088896340736  |
  | `M_LOG10E`   | log10(e)   | 0.434294481903251827651 |
  | `M_LN2`      | ln(2)      | 0.693147180559945309417 |
  | `M_LN10`     | ln(10)     | 2.30258509299404568402  |
  | `M_PI`       | pi         | 3.14159265358979323846  |
  | `M_PI_2`     | pi/2       | 1.57079632679489661923  |
  | `M_PI_4`     | pi/4       | 0.785398163397448309616 |
  | `M_1_PI`     | 1/pi       | 0.318309886183790671538 |
  | `M_2_PI`     | 2/pi       | 0.636619772367581343076 |
  | `M_2_SQRTPI` | 2/sqrt(pi) | 1.12837916709551257390  |
  | `M_SQRT2`    | sqrt(2)    | 1.41421356237309504880  |
  | `M_SQRT1_2`  | 1/sqrt(2)  | 0.707106781186547524401 |
  
  - 也可以自定义常量(自定义时用static const 关键字，不要使用宏命令，并用namespace 限定作用域)
  
    ```c++
    namespace constant{
    static const auto PI=3.14159265358979323846;
    }
    ```
    
    
  
- 枚举/枚举类中的常量：用k前缀，命名用驼峰命名规则

  ```c++
  enum{
  kSphere=0,
  kSphereOseen
  }
  ```

  

## 自定义基本数据类型(blitz)

```C++
	#include "blitz/array.h"
    template <typename T,int N>
    using Array = blitz::Array<T,N>;
    using Array4r = blitz:: Array<Real, 4>; //
    using Array3r = blitz:: Array<Real, 3>; //
    using Array2r = blitz:: Array<Real, 2>;
    using Array1r = blitz:: Array<Real, 1>;
    using Array4i = blitz::Array<int, 4>; 
    using Array3i = blitz::Array<int, 3>; 
    using Array2i = blitz::Array<int, 2>;
    using Array1i = blitz::Array<int, 1>;
    using Array4cr = blitz::Array<std::complex<Real>, 4>;
    using Array3cr = blitz::Array<std::complex<Real>, 3>;
    using Array2cr = blitz::Array<std::complex<Real>, 2>;
    using Array1cr = blitz::Array<std::complex<Real>, 1>;
    using Vec1r = blitz::TinyVector<Real, 1>;
    using Vec2r = blitz::TinyVector<Real, 2>;
    using Vec3r = blitz::TinyVector<Real, 3>;
    using Vec4r = blitz::TinyVector<Real, 4>;
    using Vec1i = blitz::TinyVector<int, 1>;
    using Vec2i = blitz::TinyVector<int, 2>;
    using Vec3i = blitz::TinyVector<int, 3>;
    using Vec4i = blitz::TinyVector<int, 4>;
    using Vec2cr = blitz::TinyVector<std::complex<Real>, 2>;
    using Vec3cr = blitz::TinyVector<std::complex<Real>, 3>;
    using Vec4cr = blitz::TinyVector<std::complex<Real>, 4>;
    using Mat4r = blitz::TinyMatrix<Real, 4, 4>;
    using Mat3r = blitz::TinyMatrix<Real, 3, 3>;
    using Mat2r = blitz::TinyMatrix<Real, 2, 2>;

    //template
    template <typename T>
    using Array1 = blitz::Array<T, 1>;
    template <typename T>
    using Array2 = blitz::Array<T, 2>;
    template <typename T>
    using Array3 = blitz::Array<T, 3>;
    template <typename T>
    using Vec1 = blitz::TinyVector<T, 1>;
    template <typename T>
    using Vec2 = blitz::TinyVector<T, 2>;
    template <typename T>
    using Vec3 = blitz::TinyVector<T, 3>;
    template <typename T>
    using Vec4 = blitz::TinyVector<T, 4>;

    template <typename T>
    using Mat2 = blitz::TinyMatrix<T, 2, 2>;
    template <typename T>
    using Mat3 = blitz::TinyMatrix<T, 3, 3>;


    template <int dim>
    using Arrayr = blitz::Array<Real, dim>;
    template <int dim>
    using Arrayi = blitz::Array<int, dim>;
    template <int dim>
    using Arraycr = blitz::Array<std::complex<Real>, dim>;



    template <int length>
    using Veci = blitz::TinyVector<int,length>;
    template <int length>
    using Vecr = blitz::TinyVector<Real, length>;
    template <int length>
    using Veccr = blitz::TinyVector<std::complex<Real>, length>;
    template <typename T,int length>
    using Vec = blitz::TinyVector<T, length>;

    template <int length>
    using Mati = blitz::TinyMatrix<int,length,length>;
    template <int length>
    using Matr = blitz::TinyMatrix<Real, length,length>;
    template <int length>
    using Matcr = blitz::TinyMatrix<std::complex<Real>, length,length>;
    template <typename T,int length>
    using Mat = blitz::TinyMatrix<T, length,length>;
```



## 命名规则

### 变量

- 普通变量，结构体内和类中的public 成员变量：统一使用小写，尽量含义清晰。对于局部变量、临时变量，尽可能用易识别的缩写，避免单词组合；对于结构体/类内的成员变量，尽可能表达内容清晰，完整，如需多单词组合，用下划线区分，如需使用缩写，请尽量用常见的缩写。

  ```
  % 局部，临时变量
  Int dim;
  Real ar; // aspect ratio,
  Real lam; // Lambda =(ar*ar-1.)/(ar*ar+1)
  Real dr; // density ratio
  % 结构体/类内成员变量
  Int idim;
  Real aspect_ratio;
  Real lam; // lambda
  Real ulam; // Lambda , up lambda
  Real density_ratio;
  Real radius;
  Real diameter;
  ```

  

- 私有变量，private,  统一小写，且在变量名前使用下划线

  ```
  Real _data;
  Real _comm;
  Real _aspect_ratio;
  ```

  

- 指针：统一用ptr_前缀，对于局部和临时的指针变量，在不引入歧义时，用p前缀, 下划线在不引起歧义时可略去

  ```c++
  Real* ptr_particle;
  Real* ptr_field;
  
  //对于局部或临时指针变量
  Real* p_particle;
  Real* pfield;
  ```
  
  

### 类/结构体，函数名

- 采用驼峰命名，在非必须，不要使用下划线。

```c++
class BlockCart;
class FluidData;
void InterpLag2Cart(...);
Real vSolver();
```

- 类中私有函数成员，也采用驼峰命名，在函数名前加下划线

  ```c++
  void _Foo();
  int _FooTest();
  ```


- 类/结构体中，用于设置和取值的成员函数，采用小驼峰命名规则

  ```c++
  void setNum(int num);
  int  getNum();
  int& refNum(); 
  ```

  

## 代码文件命名名

- 尽可能使用小写，非必要不使用下划线；
- 头文件以“.h ”为后缀
- 模板文件以“.hpp” 为后缀
- 模板文件的补充“.hxx” 为后缀
- c++程序定义文件以".cpp"为后缀
- ".h"与“.hpp”, “.hxx”后缀的文件放到include文件夹，".cpp"后缀的文件放入src文件夹

```
mesh.hpp
cartmesh.hpp
pointparticle.h
particlebase.h
particlebase.cpp
timescheme_static.hpp //当单词组合较多时，可用下划线突出需要强调的部分，以方便识别
```


## 注释约定

- 使用doxygen 注释规范，方便后面生成api文档
- 尽可能用简洁的英文，注释。部分难以用英文注释的，可用中文注释，但要尽可能避免中文注释，因为中文注释在跨平台和软件中易出现乱码。
- 变量注释： 在变量声明后，用//开始注释
- 函数注释：在函数前注释，简明用途，输入/输出接口，函数头和函数定义处保持一样
- 结构体/类注释：在结构体/类前注释，说明类名，用途，其他说明t
- 文件注释:  在文件头进行注释，说明文件主要内容，作者，版权声明等
- 节/模块注释：程序中对某一块功能的主要功能进行必要说明



# 代码习惯

## 循环

- 循环体必加花括号，左括号跟在条件语句后， 右括号与for 对齐
- 使用++i 代替i++; 同理，用--i代替i--;
- 变量定义尽可能在循环体外

```c++
int sum=0;
for(int i=0;i<N;++i){
	sum+=i;	
}
```

- 多重循环，缩进关系，表现出层次关系。
- 若循环体过长，需要在右括号后添加相关注释，以标明不同层循环体的结束
- 数组统一采用C风格的行优先策略，因此，在循环中从外到内分别为i,j,k

```
Array3i a(10,10,10);
a=10;
int sum=0;
for(int i=0; i<10; ++i){
	for(int j=0;j<10;++j){
		for(int k=0;k<10;++k){
			sum+=a(i,j,k);
			... //其他内容
		}//end of k
		...//其他内容
	}// end of j
	...//其他内容
}// end of i
```

## 函数

- 函数中的参数，尽可能使用引用，恰当使用指针，尽可能不给参数赋默认值
- 函数定义的函数体，左花括号跟在函数名参数列表后，右括号与函数名对齐

```
void Foo(int a){
	a=1;
}
```

## const 限定词

- 几种需要加const的情况
  - 常量
  - 函数传参：若传的参数只使用，不修改
  - 其它必要情况

## new 与delete配合使用

- 一个函数体内，使用new申请了空间，就必须要用delete释放
- 在类的构造或者其他成员函数中存在类成员变量的new, 就一定需要在析构函数中释放空间
- 释放空间前，请务必判断指针指定的空间是否申请。

## 指针

- 空指针，一律用nullptr 赋值，避免野指针



# 编译

- 在linux系统中使用cmake 进行编译。windows系统可用wsl或者虚拟机编译。
