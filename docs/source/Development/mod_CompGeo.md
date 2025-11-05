# 简单几何关系

## Point类

- 数据

```c++
double pos[N_dim]; // position
```

- 操作

    - 设置点的坐标(还有其他的重载版本，这里只列出一种)

        ```c++
        inline void SetPos(double p[])
        {
            for (auto i = 0; i < N_dim; ++i)
            {
                pos[i] = p[i];
            }
            return;
        }
        ```
    - 输出点，重载输出符号`<<`
        ```c++
        template <int N_dim>
        inline std::ostream &operator<<(std::ostream &os, const Point<N_dim> &x)
        {
            os << "MPI:Point: (";
            for (auto i = 0; i < N_dim; ++i)
            {
                os << x.pos[i];
                if (i != N_dim - 1)
                {
                    os << ",";
                }
            }
            os << ")\t";
            return os;
        }
        ```

## ZoneBase基类

```c++
struct ZoneBase
{
    int rank;      // 数据

    // 判断点是否位于某个区域或虚拟区域
    virtual inline bool IsInZone(const double p[]) = 0;
    virtual inline bool IsInVirtualZone(const double p[], const double r) = 0;
};
```

## CartBoxZone类

**CartBoxZone**类继承于**ZoneBase**类：
```c++
template <int N_dim>
struct CartBoxZone : public ZoneBase
{
};
```

## CartBoxZone<3>类

**CartBoxZone<3>**类继承于**ZoneBase**类：

- 数据
```c++
int rank;         // 继承于ZoneBase类
Point<3> node[8]; // nodes
```

- 操作

    - 设置某个节点坐标
        ```c++
        inline void SetNode(int i, Point<3> &point)
        {
            node[i] = point;
            return;
        }
        ```
    - 设置所有节点坐标
        ```c++
        inline void SetNodes(std::vector<Point<3>> points)
        {
            for (auto i = 0; i < 8; ++i)
            {
                node[i] = points[i];
            }
            return;
        }
        ```
    - 获得节点个数
        ```c++
        inline int GetNodeSize()
        {
            return 8;
        }
        ```
    - 判断某个点位于某个平面的哪一侧

        ```c++
        inline bool IsInPlane(int ind0, int ind1, int ind2, const double p[])
        {
            double v[3];
            // calculate the inside normal direction of plane
            v[0] = (node[ind1].pos[1] - node[ind0].pos[1]) * (node[ind2].pos[2] - node[ind0].pos[2]) - (node[ind1].pos[2] - node[ind0].pos[2]) * (node[ind2].pos[1] - node[ind0].pos[1]);
            v[1] = (node[ind1].pos[2] - node[ind0].pos[2]) * (node[ind2].pos[0] - node[ind0].pos[0]) - (node[ind1].pos[0] - node[ind0].pos[0]) * (node[ind2].pos[2] - node[ind0].pos[2]);
            v[2] = (node[ind1].pos[0] - node[ind0].pos[0]) * (node[ind2].pos[1] - node[ind0].pos[1]) - (node[ind1].pos[1] - node[ind0].pos[1]) * (node[ind2].pos[0] - node[ind0].pos[0]);

            return (v[0] * (p[0] - node[ind0].pos[0]) + v[1] * (p[1] - node[ind0].pos[1]) + v[2] * (p[2] - node[ind0].pos[2])) >= 0;
        }
        ```
    - 判断某个点是否位于区域内部
        ```c++
        virtual inline bool IsInZone(const double p[])
        {

            return IsInPlane(0, 1, 3, p) & IsInPlane(0, 3, 4, p) & IsInPlane(0, 4, 1, p) & IsInPlane(6, 2, 1, p) & IsInPlane(6, 5, 7, p) & IsInPlane(6, 7, 2, p);
        }
        ```
## CartBoxZone<2>类
- 数据
```c++
int rank;         // 继承于ZoneBase类
Point<2> node[4]; // nodes
```

- 操作

    - 设置某个节点坐标
        ```c++
        inline void SetNode(int i, Point<2> &point)
        {
            node[i] = point;
            return;
        }
        ```
    - 设置所有节点坐标
        ```c++
        inline void SetNodes(std::vector<Point<2>> points)
        {
            for (auto i = 0; i < 4; ++i)
            {
                node[i] = points[i];
            }
            return;
        }
        ```
    - 获得节点个数
        ```c++
        inline int GetNodeSize()
        {
            return 8;
        }
        ```
    - 判断某个点位于某个线的哪一侧

        ```c++
        inline bool IsInPlane(int ind0, int ind1, const double p[])
        {
            return (node[ind1].pos[0] - node[ind0].pos[0]) * (p[1] - node[ind0].pos[1]) - (node[ind1].pos[1] - node[ind0].pos[1]) * (p[0] - node[ind0].pos[0]) >= 0.;
        }
        ```
    - 判断某个点是否位于平面内部
        ```c++
        virtual inline bool IsInZone(const double p[])
        {
            return IsInPlane(0, 1, p) & IsInPlane(1, 2, p) & IsInPlane(2, 3, p) & IsInPlane(3, 0, p);
        }
        ```

## SimpleCartBoxZone类
**SimpleCartBoxZone**类继承于**ZoneBase**类：
```c++
template <int N_dim>
struct SimpleCartBoxZone : public ZoneBase
{
};
```

## SimpleCartBoxZone<3>类

**SimpleCartBoxZone<3>**类继承于**ZoneBase**类：

- 数据
```c++
int rank;         // 继承于ZoneBase类
double b[2 * 3];  // 每个方向有上下两个端点，三个方向共六个
```

- 操作

    - 设置x方向的端点
        ```c++
        inline double &bx(const int i)
        {
            return b[i];
        }
        ```
    - 设置y方向的端点
        ```c++
        inline double &by(const int i)
        {
            return b[2 + i];
        }
        ```
    - 设置z方向的端点
        ```c++
        inline double &bz(const int i)
        {
            return b[4 + i];
        }
        ```
    - 设置选定方向的端点
        ```c++
        inline void SetBoundaryEdges(int i, const std::vector<double> &bd)
        {
            if (i == 0)
            {
                bx(0) = bd[0];
                bx(1) = bd[1];
            }
            else if (i == 1)
            {
                by(0) = bd[0];
                by(1) = bd[1];
            }
            else if (i == 2)
            {
                bz(0) = bd[0];
                bz(1) = bd[1];
            }
            return;
        }
        ```
    - 设置所有方向的端点
        ```c++
        inline void SetBoundaryEdges(const std::vector<std::vector<double>> &bds)
        {
            SetBoundaryEdges(0, bds[0]);
            SetBoundaryEdges(1, bds[1]);
            SetBoundaryEdges(2, bds[2]);
            return;
        }
        ```
    - 获得端点个数
        ```c++
        inline int GetSize()
        {
            return 6;
        }
        ```
    - 判断某个点是否位于区域内部

        ```c++
        virtual inline bool IsInZone(const double p[])
        {

            return ((bx(0) - p[0]) * (bx(1) - p[0]) <= 0) & ((by(0) - p[1]) * (by(1) - p[1]) <= 0) & ((bz(0) - p[2]) * (bz(1) - p[2]) <= 0);
        }
        ```
    - 判断某个点是否位于虚拟区域内部
        ```c++
        virtual inline bool IsInVirtualZone(const double p[], const double r)
        {

            return (!IsInZone(p)) & ((bx(0) - r - p[0]) * (bx(1) + r - p[0]) <= 0) & ((by(0) - r - p[1]) * (by(1) + r - p[1]) <= 0) & ((bz(0) - r - p[2]) * (bz(1) + r - p[2]) <= 0);
        }
        ```

## SimpleCartBoxZone<2>类

**SimpleCartBoxZone<2>**类继承于**ZoneBase**类：

- 数据
```c++
int rank;         // 继承于ZoneBase类
double b[4];  // 每个方向有上下两个端点，两个方向共四个
```

- 操作

    - 设置x方向的端点
        ```c++
        inline double &bx(const int i)
        {
            return b[i];
        }
        ```
    - 设置y方向的端点
        ```c++
        inline double &by(const int i)
        {
            return b[2 + i];
        }
        ```
    - 设置选定方向的端点
        ```c++
        inline void SetBoundaryEdges(int i, const std::vector<double> &bd)
        {
            if (i == 0)
            {
                bx(0) = bd[0];
                bx(1) = bd[1];
            }
            else if (i == 1)
            {
                by(0) = bd[0];
                by(1) = bd[1];
            }
            return;
        }
        ```
    - 设置所有方向的端点
        ```c++
        inline void SetBoundaryEdges(const std::vector<std::vector<double>> &bds)
        {
            SetBoundaryEdges(0, bds[0]);
            SetBoundaryEdges(1, bds[1]);
            return;
        }
        ```
    - 获得端点个数
        ```c++
        inline int GetSize()
        {
            return 4;
        }
        ```
    - 判断某个点是否位于区域内部

        ```c++
        inline bool IsInZone(const double p[])
        {
            return ((bx(0) - p[0]) * (bx(1) - p[0]) <= 0) & ((by(0) - p[1]) * (by(1) - p[1]) <= 0);
        }
        ```
    - 判断某个点是否位于虚拟区域内部
        ```c++
        inline bool IsInVirtualZone(const double p[], const double r)
        {
            return (!IsInZone(p)) & ((bx(0) - r - p[0]) * (bx(1) + r - p[0]) <= 0) & ((by(0) - r - p[1]) * (by(1) + r - p[1]) <= 0);
        }
        ```