// This file contains a struct that holds laser scan data

// Include guard
#ifndef __LASER_DATA__
#define __LASER_DATA__

// Include namespaces for convenience in code writing
using namespace std;

// This object stores the (x,y) coordinates of two paired points
struct LaserData
{
    double range;
    double bearing;
    LaserData() : range(0), bearing(0)  {}
    LaserData(const double r, const double b) : range(r), bearing(b)    {}
};
// This function prints out a LaserData as range, bearing
ostream& operator<<(ostream& os, const LaserData& ld)
{
    os << ld.range << ", " << ld.bearing;
    return os;
}
// This function reads in a LaserData given as range, bearing
istream& operator>>(istream& s, LaserData& dp)
{
    double range = 0, bearing = 0;  // initialize components of vector to read in.
    char ch = 0;                    // characters read in from string

    if (!s)     {return s;}     // stream invalid, just return fail state

    // Read in each component and return if invalid syntax occurs
    s >> range >> ch;
    if (ch != ',') {s.clear(ios_base::failbit); return s;}  // no ',' between num
    s >> bearing >> ch;

    // Everything valid, create Color
    dp = LaserData(range, bearing);

    return s;
}

// This object stores the (x,y,yaw) pose of a robot
struct Pose
{
    double x;
    double y;
    double yaw;
    Pose() : x(0), y(0), yaw(0)  {}
    Pose(const double x, const double y, const double yaw) : x(x), y(y), yaw(yaw) {}
};
// This function prints out a Pose as x, y, yaw
ostream& operator<<(ostream& os, const Pose& p)
{
    os << p.x << ", " << p.y << ", " << p.yaw;
    return os;
}
// This function reads in a Pose given as x, y, yaw
istream& operator>>(istream& s, Pose& p)
{
    double x = 0, y = 0, yaw = 0;   // initialize components of vector to read in.
    char ch = 0;                    // characters read in from string

    if (!s)     {return s;}     // stream invalid, just return fail state

    // Read in each component and return if invalid syntax occurs
    s >> x >> ch;
    if (ch != ',') {s.clear(ios_base::failbit); return s;}  // no ',' between num
    s >> y >> ch;
    if (ch != ',') {s.clear(ios_base::failbit); return s;}  // no ',' between num
    s >> yaw >> ch;

    // Everything valid, create Color
    p = Pose(x, y, yaw);

    return s;
}

#endif // __LASER_DATA__
