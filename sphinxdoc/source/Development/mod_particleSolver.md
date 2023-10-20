# 点颗粒求解器

具体代码实现请见文件夹**Solver/PPSol/**。**PPSolBase**类继承于基类**Solver**，基类利用静态成员为所有的求解器提供公共配置参数。点颗粒求解器**CartPPSol**类继承于**PPSolBase** 类和 **CartDataSpace<N_dim>** 类，该类用于求解笛卡尔坐标系下的点颗粒问题。关于 **CartDataSpace<N_dim>** 类的说明请查看[流体求解器和颗粒求解器共享的数据空间](mod_CartDataSpace.md)部分。

## 一、数据

### 1、TimeScheme

颗粒推进的时间格式：
    
```c++
enum class TimeScheme
{
    Default = 0,
    AB2 = 1
};
```
### 2、InitMethod
颗粒初始化的方式：
```c++
enum class InitMethod
{
    Default = 0,
    RandomAll = 1,
    FromFile = 2
};
```
### 3、CoupleType
点颗粒求解时的耦合方式：
```c++
enum class CoupleType
{
    OneWay = 0,
    TwoWay,
    ThreeWay,
    FourWay
};
```
### 4、 其他数据
位于**Solver**基类：


位于**PPSolBase**类：
```c++
static inline Real dtp = 0.; // particle time interval
static inline Real dtc = 0.; // particle collision time interval
```

位于**CartPPSol**类：
```C++
// array of pointers of particle models
Array1<dmdyn::PointParticleModel *> ptr_particle;
// a temporary pointer of particle model
static inline dmdyn::PointParticleModel *ptr_part_temp = nullptr; 
// total number of the types of particle models
int typenum, localsize;                                           

// references of some public variables in CartDataSpace
// reference to the cartblock
blockelm::CartBlock<N_dim> &block = CartDataSpace<N_dim>::cartblock;  
// reference to domain size of local block                 
std::vector<std::vector<Real>> &domain_size = CartDataSpace<N_dim>::domain_size; 
// reference to global domain size      
std::vector<std::vector<Real>> &gb_domain_size = CartDataSpace<N_dim>::gb_domain_size; 
// reference to MPI communicator
gsmpi::GSMPICart<N_dim> &mpicomm = CartDataSpace<N_dim>::mpicomm;                      

gsmpi::SerializedBuffer psendbuff; // a buffer for sending particle information
gsmpi::SerializedBuffer precvbuff; // a buffer for receiving particle information

// record neighbor zone/block list
Array1<compgeo::SimpleCartBoxZone<N_dim>> zonelist;
// send counts of particles
Array1i sendcounts;            
// send counts of particles which are considered as virtual particles in neighbor zones/blocks
Array1i virtsendcounts;        
Real max_particle_length = 0.; // the maximum length(size) of particle

SmartPList<ParticleField<N_dim>> partfieldlist; // particle field list with all kinds of particles
dmdyn::PPContact<N_dim> ppcontact;              // the contact of particles by kd-tree
CartPPVirtualRegion<N_dim> ppvirt;              // store some information of virtual particles

struct
{
    std::string part_type;      // ppsol_type: single particle
    std::string part_info_path; // path of PartInfo.in
    std::string work_path;      // path of particle work file
    InitMethod init_pos_method;
    InitMethod init_orient_method;
    std::string init_pos_filename;
    std::string init_orient_filename;
    CoupleType couple_type;
    int ratio_dt_dtp;
    int ratio_dtp_dtc;
    TimeScheme time_scheme;
    int interp_order;
    int conti; // continue flag
    ContactComponent coll_comp;
} ppdict;
```
## 二、操作 