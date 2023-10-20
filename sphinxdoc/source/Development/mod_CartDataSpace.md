# 流体求解器和颗粒求解器共享的数据空间

## 数据

```c++
// domain size
static inline std::vector<std::vector<Real>> domain_size;    // local domain size
static inline std::vector<std::vector<Real>> gb_domain_size; // global domain size

//  mesh
static inline std::vector<int> mesh_size;                 // local mesh size for one rank, excluding ghost mesh
static inline std::vector<int> gb_mesh_size;              // global domain size, excluding ghost mesh
static inline std::vector<std::vector<int>> ghost_size;   // ghost mesh
static inline std::vector<std::vector<int>> stagger_flag; // flag for stagger grids
static inline const std::vector<int> center_flag = {0, 0, 0};
static inline blockelm::CartMesh<N_dim> gb_cartmesh; // global cartesian mesh

// block
static inline blockelm::CartBlock<N_dim> cartblock; // block, including fluid data for local processor

// mpi
static inline gsmpi::GSMPICart<N_dim> mpicomm; // mpi communicator

static inline tml::tmlnode dataspacetml;
static inline struct
{
    std::vector<Real> domain_size;
    std::vector<int> mesh_size;
    std::vector<int> ghost_size;
    std::vector<int> stagger_flag;
} dataspacedict;

```

## 方法

- 读入`CARTDATASPACE`数据，并调用`mpicomm.InitMPI(nprocs, isperoid);`进行并行的设置,再调`CheckConfigDataSpaceDict();`函数设置各个进程负责的局部区域大小、网格大小、虚拟网格大小和交错网格的设置：

    ```c++
    inline void ConfigDataSpaceDict()
    {
        dataspacetml = database::controldict["CARTDATASPACE"];
        auto glbtml = dataspacetml.as_table();

        auto nprocs = tml::readVec<int>(glbtml, "MPI.Procs");
        auto isperoid = tml::readVec<int>(glbtml, "MPI.PeroidFlags");
        mpicomm.InitMPI(nprocs, isperoid);

        auto &dsdict = dataspacedict;
        dsdict.domain_size = tml::readVec<Real>(glbtml, "DomainSize");
        dsdict.mesh_size = tml::readVec<int>(glbtml, "MeshSize");
        dsdict.ghost_size = tml::readVec<int>(glbtml, "GhostSize");
        dsdict.stagger_flag = tml::readVec<int>(glbtml, "StaggeredFlags", {0, 0, 0});

        CheckConfigDataSpaceDict();
    }
    ```

- `CheckConfigDataSpaceDict()`函数：

    ```c++
    void CheckConfigDataSpaceDict()
    {
        auto &dsdict = dataspacedict;

        if (dsdict.domain_size.size() == 2)
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                gb_domain_size.push_back(dsdict.domain_size);
            }
        }
        else if (dsdict.domain_size.size() == (N_dim * 2))
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                gb_domain_size.push_back({dsdict.domain_size[i * 2], dsdict.domain_size[i * 2 + 1]});
            }
        }
        else
        {
            std::string serr = "[Error at CartDataSpace::CheckConfigFlowDict] the input domain size is not correct\n";
            throw serr;
        }
        // local domain size
        Real s;
        for (auto i = 0; i < N_dim; ++i)
        {
            s = (gb_domain_size[i][1] - gb_domain_size[i][0]) / mpicomm.GetProc(i);
            domain_size.push_back({gb_domain_size[i][0] + mpicomm.GetCoord(i) * s, gb_domain_size[i][0] + (mpicomm.GetCoord(i) + 1) * s});
        }

        if (dsdict.mesh_size.size() >= N_dim)
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                gb_mesh_size.push_back(dsdict.mesh_size[i]);
            }
        }
        else
        {
            std::string serr = "[Error at CartDataSpace::CheckConfigFlowDict] the input mesh size is not correct\n";
            throw serr;
        }
        for (auto i = 0; i < N_dim; ++i)
        {
            if (gb_mesh_size[i] % mpicomm.GetProc(i) == 0)
            {
                mesh_size.push_back(gb_mesh_size[i] / mpicomm.GetProc(i));
            }
            else
            {
                std::string serr = "[Error at CartDataSpace::CheckConfigFlowDict] the input mesh size cannot be divided by proc with no remainder \n";
                throw serr;
            }
        }

        // check ghost size
        if (dsdict.ghost_size.size() == 1)
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                ghost_size.push_back({dsdict.ghost_size[0], dsdict.ghost_size[0]});
            }
        }
        else if (dsdict.ghost_size.size() == N_dim)
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                ghost_size.push_back({dsdict.ghost_size[i], dsdict.ghost_size[i]});
            }
        }
        else if (dsdict.ghost_size.size() == (2 * N_dim))
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                ghost_size.push_back({dsdict.ghost_size[i * 2], dsdict.ghost_size[i * 2 + 1]});
            }
        }
        else
        {
            std::string serr = "[Error at CartDataSpace::CheckConfigFlowDict] the input ghost size is not correct\n";
            throw serr;
        }
        std::cout << "check over of ghost size" << std::endl;
        // check staggered Flags
        if (dsdict.stagger_flag.size() >= N_dim)
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                std::vector<int> sf;
                for (auto j = 0; j < N_dim; ++j)
                {
                    sf.push_back(0);
                }
                stagger_flag.push_back(sf);
                if (dsdict.stagger_flag[i] == 1)
                {
                    stagger_flag[i][i] = 1;
                }
            }
        }
        else
        {
            std::string serr = "[Error at CartDataSpace::CheckConfigFlowDict] the input stagger flag is not correct\n";
            throw serr;
        }
    }
    ```

- 计算全局的数据大小，其中`flag`参数一般是指定义在网格中心的还是网格面心的数据：

    ```c++
    static std::vector<int> CalTotalShape(const std::vector<int> &flag)
    {
        std::vector<int> shapetotal;
        for (auto i = 0; i < N_dim; ++i)
        {
            if (flag[i] == 0)
            { // center
                shapetotal.push_back(gb_mesh_size[i] + ghost_size[i][0] + ghost_size[i][1]);
            }
            else
            {
                shapetotal.push_back(gb_mesh_size[i] + ghost_size[i][0] + ghost_size[i][1] + 1);
            }
        }
        return shapetotal;
    }
    ```