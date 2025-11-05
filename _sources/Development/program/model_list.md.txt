# 颗粒受力模型列表工作原理

## 背景与动机
1. 颗粒种类繁多，颗粒的受力模型丰富。在我们旧版本的fortran程序PARTURB中，我们通过预设颗粒模型的受力方案来区分不同种类的颗粒力，例如：
   > 球形：经验阻力公式+升力+重力
2. 实际问题中，颗粒的受力模型繁多，仅阻力模型就比较多，如果仍然采用预设方案，所需要的排列组合的颗粒种类非常庞大。而在大多数情况下，科研者主要关心一些常用的组合，同时也需要能够自定义颗粒的受力的组合形式。
3. 为了进一步简化力模型添加和调用的过程。如果采用之前预设方案，需要有大段重复的代码，而且可维护性随着颗粒种类的增加而变差。我们需要一种**颗粒受力模型**列表，帮助我们管理模型，并且可以根据列表中的模型顺序自动化执行。

## 基本方案

1. 从字典文件输入颗粒力模型和力矩模型列表
例如
    ```toml
    FM=["Stokes", "Saffman", "Basset"]
    TM=["Jeffery", "FluidInertialTorque"]
    ```
    - 以上模型的名字未来可能尽可能简写，尽可能保证3-6个字符之间
    - 对应颗粒可自定义相应的模型，例如
    ```toml
    0={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1,1,1], G=[0,0,0], FM=["Stokes"], TM=["Stokes"]}
    1={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1,1,1], G=[0,0,0], FM=["Oseen",     "Saffman"], TM=["Stokes"]}
    2={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1,1,1], G=[0,0,0], FM=["MaxeyRily", "Saffman", "Basset"], TM=["Stokes"]}
    3={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1,1,1], G=[0,0,0], FM=["Stokes"], TM=["Stokes"]}
    ```
    其中让ModelID=1~99预留出来作为用户自定义的大类标签，比如1为自定义普通球形颗粒，2为自定义普通非球形颗粒等.
2. 由程序读取列表，并解析颗粒所需力模型，在颗粒求解过程中依次执行相应的模型叠加。

3. 通过ModelID预置一些常用的组合

    比如三位到四位的ModelID作为预置模型，比如ModelID=105(具体以发布版本说明为准), 为惯性球形颗粒，其中颗粒受力模型为 Stokes+Saffman, 力矩模型为StokesTorque.

## 实现方案
### 模型设计
1. 拟采用vector作为容器存储各个模型的指针，并与不同种类的颗粒进行绑定
2. 各个受力模型，拟采用class的继承方案，例如
    ```C++
    template <typename T_real, int N_dim=3>
        requires (N_dim==3 || N_dim==2)
        struct SphereForceModel
        {
            struct Stokes:public ForceModel{
                virtual const std::string getName(){
                    return "Sphere::"+std::to_string(N_dim)+"D Stokes Force";
                }
                virtual void Force(ParticleField<N_dim> & pfield, ParticleBase* ptr_particle){

                }
            };
            struct Oseen:public ForceModel{
                virtual const std::string getName(){
                    return "Sphere::"+std::to_string(N_dim)+"D Oseen Force";
                }
                virtual void Force(ParticleField<N_dim> & pfield, ParticleBase* ptr_particle){

                }
            };
    ```
其中 ForceModel 为所有力模型的基类。
