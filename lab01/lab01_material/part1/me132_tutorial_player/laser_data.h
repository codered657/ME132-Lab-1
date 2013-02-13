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
// This function prints out a LaserData as [range, bearing]
ostream& operator<<(ostream& os, const LaserData& ld)
{
    os << "[" << ld.range << ", " << ld.bearing << "]";
    return os;
}
// This function reads in a LaserData given as [range, bearing]
istream& operator>>(istream& s, LaserData& dp)
{
    double range = 0, bearing = 0;  // initialize components of vector to read in.
    char ch = 0;                    // characters read in from string

    if (!s)     {return s;}     // stream invalid, just return fail state

    // Read in each component and return if invalid syntax occurs
    s >> ch;
    if (ch != '[') {s.clear(ios_base::failbit); return s;}  // no starting paren
    s >> range >> ch;
    if (ch != ',') {s.clear(ios_base::failbit); return s;}  // no ',' between num
    s >> bearing >> ch;
    if (ch != ']') {s.clear(ios_base::failbit); return s;}  // no closing paren

    // Everything valid, create Color
    dp = LaserData(range, bearing);

    return s;
}

#endif // __LASER_DATA__
