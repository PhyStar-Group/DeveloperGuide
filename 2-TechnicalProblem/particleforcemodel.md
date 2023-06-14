# 颗粒受力模型重构

考虑颗粒模型的模块化与易用性，对颗粒受力模型部分进行一定重构，

## 实现的功能
1. 颗粒根据输入颗粒力模型和力矩模型列表，颗粒依次执行相应的模型进行叠加。
例如
    ```toml
    FM=["Stokes", "Saffman", "Basset"]
    TM=["Jeffery", "FluidInertialTorque"]
    ```
    - 以上模型的名字未来可能尽可能简写，尽可能保证3-6个字符之间
    - 对应颗粒可自定义相应的模型，例如
    ```toml
    0={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1.,1.,1.], G=[0.,0.,0.], FM=["Stokes"]}
    1={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1.,1.,1.], G=[0.,0.,0.], FM=["Oseen",     "Saffman"]}
    2={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1.,1.,1.], G=[0.,0.,0.], FM=["MaxeyRily", "Saffman", "Basset"]}
    3={ModelID=1,Size=100,DR=1000,Radius=0.001, AR=[1.,1.,1.], G=[0.,0.,0.], FM=[]}
    ```
    其中让ModelID=1~99预留出来作为用户自定义的大类标签，比如1为自定义普通球形颗粒，2为自定义普通非球形颗粒等.

2. 预置一些常用的模型组合
    而三位到四位的ModelID作为预置模型，比如ModelID=105(具体以发布版本说明为准), 为惯性球形颗粒，其中颗粒受力模型为 Stokes+Saffman, 力矩模型为StokesTorque.

## 实现方案
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
                virtual void addForce(ParticleField<N_dim> & pfield, ParticleBase* ptr_particle){

                }
            };
            struct Oseen:public ForceModel{
                virtual const std::string getName(){
                    return "Sphere::"+std::to_string(N_dim)+"D Oseen Force";
                }
                virtual void addForce(ParticleField<N_dim> & pfield, ParticleBase* ptr_particle){

                }
            };
    ```
其中 ForceModel 为所有力模型的基类。
