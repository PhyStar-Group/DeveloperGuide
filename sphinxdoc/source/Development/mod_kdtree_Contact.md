# 颗粒间相互作用设计

## 颗粒之间相互作用搜索

颗粒之间相互作用搜索主要由`KDTreeFlann`类实现，该类调用`nanoflann`开源代码实现颗粒间相互作用的搜索，关于本开源代码的使用请参考以下链接[nanoflann](https://github.com/jlblancoc/nanoflann)，下面进行介绍：

- PointCloud类
    本类定义在文件`PhyStar/Algo/KNN/utils.h`中，主要用来构建颗粒云：

    - 数据
        ```c++
        struct Point
        {
            T x, y, z;
        };

        std::vector<Point> pts;
        ```
    - 方法
        - 返回颗粒云中颗粒的数量：

            ```c++
            inline size_t kdtree_get_point_count() const 
            { 
                return pts.size(); 
            }
            ```
        - 返回颗粒云中第`idx`个颗粒的第`dim`个位置分量：
            ```c++
            inline T kdtree_get_pt(const size_t idx, const size_t dim) const
                {
                    if (dim == 0)
                        return pts[idx].x;
                    else if (dim == 1)
                        return pts[idx].y;
                    else
                        return pts[idx].z;
                }
            ```

        - 暂时理解为占位函数吧：
            ```c++
                template <class BBOX>
                bool kdtree_get_bbox(BBOX & /* bb */) const
                {
                    return false;
                }
            ```
- KDTreeFlann类

    - 数据
        ```c++
        PointCloud<Real> cloud;

        // construct a kd-tree index:
        using my_kd_tree_t = nanoflann::KDTreeSingleIndexAdaptor<
                    nanoflann::L2_Simple_Adaptor<Real, PointCloud<Real>>,
                    PointCloud<Real>, N_dim>;

        my_kd_tree_t *ptr_index = nullptr;
        std::vector<nanoflann::ResultItem<uint32_t, Real>> ret_matches;
        std::vector<uint32_t> indices;
        std::vector<Real> dist;

        ```


    - 方法
        - 建立颗粒云：
            ```c++
            auto &BuildFromIterator(auto itbegion, auto itend, const size_t maxleaf = 10)
            {
                cloud.pts.clear();
                int ip = 0;
                PointCloud<Real>::Point p = {0, 0, 0};
                for (auto it = itbegion; it != itend; it++)
                {
                    p.x = (*it).pdata.pos(0);
                    if constexpr (N_dim > 1)
                    {
                        p.y = (*it).pdata.pos(1);
                    }
                    if constexpr (N_dim > 2)
                    {
                        p.z = (*it).pdata.pos(2);
                    }
                    cloud.pts.push_back(p);      // add a particle to the cloud
                }
                if (ptr_index != nullptr)
                {
                    delete ptr_index;
                    ptr_index = nullptr;
                }
                ptr_index = new my_kd_tree_t(N_dim, cloud, {maxleaf});
                return *this;
            };
            ```

        - 搜索颗粒附近给定距离的颗粒，返回邻近颗粒的`index`和对应的距离`distance`：
            ```c++
            std::pair<std::vector<uint32_t>, std::vector<Real>> Search(const Real pos[], const Real radius)
            {
                ret_matches.clear();

                auto nMatches = ptr_index->radiusSearch(pos, radius * radius, ret_matches);

                indices.resize(nMatches);
                dist.resize(nMatches);
                for (size_t i = 0; i < nMatches; i++)
                {
                    indices[i] = ret_matches[i].first;
                    dist[i] = std::sqrt(ret_matches[i].second);
                }
                return {indices, dist};
            }
            ```


## 颗粒间的接触设计

颗粒间的接触主要由**PPContact**类进行控制，其记录可能发生碰撞的颗粒和不可能发生碰撞的颗粒，记录接触模型等等，下面进行介绍：

- 数据
    - `ptr_particle_base`存储颗粒的模型列表，在函数`Init()`进行设置；
    - `contact_comp`存储发生接触的颗粒之间的类型，控制碰撞是否只发生在同一类型的颗粒(`Single`)或不同类型的颗粒(`Multi`)之间，在函数`Init()`进行设置；
    - `contact_models`存储颗粒的接触模型列表，在函数`ContactModelListGenerate()`中进行设置；


    ```c++
    // storing index for particles which could be contacted
    std::vector<int> possible_contact_index;
    // storing index for particles which cannot be contacted 
    std::vector<int> no_possible_contact_index;

    algo::KDTreeFlann<N_dim> tree; // estabilsh  Flann KDtree 

    using CM_ptr = std::shared_ptr<ContactModel>;
    std::vector<CM_ptr> contact_models;

    /**
        * @brief hash of std::pair to establish a hash map
        *
        */
    struct Pair_Hash
    {
        template <typename T1, typename T2>
        std::size_t operator()(const std::pair<T1, T2>& p) const
        {
            auto h1 = std::hash<T1>{}(p.first);
            auto h2 = std::hash<T2>{}(p.second);
            return h1 ^ h2;
        }
    };

    std::unordered_map<std::pair<uIntl, uIntl>, ContactStatus, Pair_Hash> contact_pairs;
    // the base of pointer list of pointer of PointParticleModel
    PointParticleModel** ptr_particle_base = nullptr; 
    ContactComponent contact_comp = ContactComponent::Single;
    uIntl coll_count = 0;
    ```

- 方法

    - 为每个颗粒搜索邻近的颗粒(不包括虚拟颗粒)，将有可能发生接触作用的颗粒记录在**PPContact**类的`possible_contact_index`变量中，将不可能发生接触作用的颗粒记录在`no_possible_contact_index`变量中，并将颗粒的邻居颗粒记录在**ParticleField**类中的`nbrs_pp_index`变量中。
        ```c++
        void SearchingParticlePairs(auto& pflist, const Real search_radius)
        {
            possible_contact_index.clear();
            no_possible_contact_index.clear();
            tree.BuildFromIterator(pflist.begin(), pflist.vend(), 10);
            for (auto i = 0; i < pflist.MaxLength(); ++i)
            {
                auto [ind, dist] = tree.Search(pflist(i).pdata.pos.data(), search_radius);
                pflist(i).nbrs_pp_index.clear();
                if (ind.size() <= 1)
                {
                    no_possible_contact_index.push_back(ind[0]); // the self particle
                }
                else
                {
                    possible_contact_index.push_back(ind[0]);
                    pflist(i).nbrs_pp_index.resize(ind.size() - 1);
                    for (auto ip = 0; ip < ind.size() - 1; ++ip)
                    {
                        pflist(i).nbrs_pp_index[ip] = ind[ip + 1];
                    }
                }
            }
        }
        ```
    
    - 清除已经记录的接触的颗粒对：

        ```c++
        inline void ClearContactPairs()
        {
            contact_pairs.clear();
        }
        ```

    - 添加已经接触的颗粒对，将其存储在变量`contact_pairs`中：
        ```C++
        inline void AddContactPair(uIntl i, uIntl j)
        {
            if (i > j)
            {
                std::swap(i, j);
            }
            std::pair<uIntl, uIntl> ij = { i, j };
            if (contact_pairs.count({ i, j }) < 1)
            {
                contact_pairs.emplace(ij, ContactStatus::Contact);
                // std::cout<<i<<"\t"<<j<<std::endl;
            }
        }
        ```

    - 记录颗粒碰撞次数：
        ```c++
        inline void CollisionCount(uIntl i, uIntl j, const ContactStatus cont_status, const uIntl maxlength)
        {
            if (cont_status == ContactStatus::Contact)
            {
                return;
            }
            else
            {
                if (i > j)
                {
                    std::swap(i, j);
                }
                uIntl increment = 2;
                if (contact_pairs.count({ i, j }) == 1)
                {
                    if (contact_pairs[{i, j}] == ContactStatus::Contact)
                    {
                        if (j >= maxlength)
                        {
                            increment = 1;         // collide with the virtual particle only counts once
                        }
                        coll_count += increment;   // collide with the particle counts twice
                        contact_pairs[{i, j}] = ContactStatus::Do_Not_Contact;
                        // std::cout<<i<<"\t"<<j<<std::endl;
                    }
                }
            }
        }
        ```



    - 初始化颗粒碰撞次数，将其置为零：
        ```c++
        inline void InitCollisionCount()
        {
            coll_count = 0;
        }
        ```

    
    - 生成接触模型列表，并存储在`contact_models`变量中，在颗粒求解器中调用函数`CreateParticle()`进行设置：
        ```c++
        void ContactModelListGenerate(const std::vector<std::string>& strlist) {
            contact_models.clear();
            for (auto& str : strlist)
            {
                if (str == "GhostCollision")
                {
                    contact_models.push_back(CM_ptr(new typename PPContactModel<N_dim>::GhostCollision(ptr_particle_base)));
                }
                else if (str == "GlowinskiCollision")
                {
                    contact_models.push_back(CM_ptr(new typename PPContactModel<N_dim>::GlowinskiCollision(ptr_particle_base)));
                }
                else
                {
                    std::string serr = "[Error At PPContact::ContactModelListGenerate]:" + str + " was not defined\n";
                    throw serr;
                }
            }
        }
        ```
    
    - 初始化，设置颗粒间接触的类型，是否只限定为同种颗粒间的接触还是多种颗粒间的接触，并且传递颗粒模型列表，这个函数在颗粒求解器里面调用函数`Prepare()`进行设置：
        ```c++
        inline void Init(PointParticleModel** ptr_p, const ContactComponent contactcomp = ContactComponent::Single)
        {
            ptr_particle_base = ptr_p;
            // cont_model = collmodel;
            contact_comp = contactcomp;
        }
        ```

    - 调用对应的接触模型进行接触力的计算，并将接触力存储在对应的颗粒的`ParticleField`类的`contact_force`变量中，同时计算颗粒间的接触力矩，并将其存储在存储在对应的颗粒的`ParticleField`类的`contact_torque`变量中，并返回颗粒之间的接触状态，这个函数在颗粒求解器里面调用函数`vSolve()`进行设置：
        ```c++
        ContactStatus Force(auto& pf_i, auto& pf_j, const Real alpha = 1., const Real beta = 0., const bool whether_only_detect_contact = false)
        {
            if ((contact_comp == ContactComponent::Single) & (pf_i.particle_typeid != pf_j.particle_typeid))
            {
                return ContactStatus::Do_Not_Contact;
            }
            if (whether_only_detect_contact) {
                return WhetherContacted(pf_i, pf_j);
            }
            else {
                for (auto& cm : contact_models) {
                    cm->Force(pf_i, pf_j, alpha, beta);
                }
                return WhetherContacted(pf_i, pf_j);
            }
        }
        ```
    
    - 返回颗粒间的接触状态，是接触还是没有接触：
        ```c++
        ContactStatus WhetherContacted(auto& pf_i, auto& pf_j) {
            if (WhichContactShapeType(pf_i, pf_j) == ContactShapeType::SphereToSphere) {
                auto dist = Distance(pf_i, pf_j);
                auto p_part0 = *(ptr_particle_base + pf_i.particle_typeid);
                auto p_part1 = *(ptr_particle_base + pf_j.particle_typeid);
                auto r0 = p_part0->Radius();
                auto r1 = p_part1->Radius();
                auto delta = r0 + r1 - dist;
                if (delta > 0)
                {
                    return ContactStatus::Contact;
                }else{
                    return ContactStatus::Do_Not_Contact;
                }

            }
            else if (WhichContactShapeType(pf_i, pf_j) == ContactShapeType::EllipsoidToEllipsoid) {
                return ContactStatus::Do_Not_Contact;

            }
            else {
                return ContactStatus::Do_Not_Contact;
            }
        }
        ```

    - 返回颗粒之间的碰撞类型：
        ```c++
        ContactShapeType WhichContactShapeType(auto& pf_i, auto& pf_j)
        {
            auto p_part0 = *(ptr_particle_base + pf_i.particle_typeid);
            auto p_part1 = *(ptr_particle_base + pf_j.particle_typeid);
            auto shapeid0 = p_part0->ShapeID();
            auto shapeid1 = p_part1->ShapeID();
            if (shapeid0 == ShapeType::Sphere & shapeid1 == ShapeType::Sphere)
            {
                return ContactShapeType::SphereToSphere;
            }
            else if (shapeid0 == ShapeType::Spheroid | shapeid0 == ShapeType::Ellipsoid |
                shapeid1 == ShapeType::Spheroid | shapeid1 == ShapeType::Ellipsoid)
            {
                return ContactShapeType::EllipsoidToEllipsoid;
            }
            else
            {
                return ContactShapeType::EllipsoidToEllipsoid;
            }
        }
        ```


## 颗粒接触模型基类


## 颗粒接触模型


## 颗粒相互作用的一些枚举类型

- 控制颗粒之间的碰撞类型：
    ```c++
    enum class ContactShapeType
    {
        None = 0,
        SphereToSphere,
        EllipsoidToEllipsoid
    };
    ```

- 控制颗粒之间的接触状态：
    ```c++
    enum class ContactStatus
    {
        Do_Not_Contact = 0, //contact model does not work yet
        Contact             //contact model works
    };
    ```

- 控制碰撞是否只发生在同一类型的颗粒(`Single`)或不同类型的颗粒(`Multi`)之间
    ```c++
    enum class ContactComponent
    {
        Single = 0,
        Multi,
    };
    ```
