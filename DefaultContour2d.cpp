#include "DefaultContour2d.h"

DefaultContour2d::DefaultContour2d(std::pair<TripleTuple> coordinates):
    Contour2d(coordinates)
{
    coordinatesParameters_=getCoordinatesParameters();     // e.g. 'x' or 'theta'
}
double DefaultContour2d::getPointParameter1_(const TripleTuple& point){
    return point.first; // the x coordinate
}
double DefaultContour2d::getPointParameter2_(const TripleTuple& point){
    return point.second; // the y coordinate
}
double DefaultContour2d::getPointValue_(const TripleTuple& point){
    return point.third; // the z coordinate
}
std::tuple<TripleTuple,TripleTuple,TripleTuple>DefaultContour2d::getSegment_(double parameter1, double parameter2){
    //loop over coordinates paramters and compare with parameter
    std::tuple<TripleTuple,TripleTuple,TripleTuple> segment;
    int i=0;
    int j=0;
    for (std::vector<double>::iterator it= coordinatesParameters_.begin().first
            ;it !=coordinatesParameters_.end().first;it++){
    {
       for (std::vector<double>::iterator it2= coordinatesParameters_.first.begin()
            ;it2 !=coordinatesParameters_.first.end();it2++){ 
        if (parameter1 < *it && parameter2 <*it2){
            segment=std::make_tuple(coordinates_[i-1][j-1],coordinates_[i][j-1],coordinates_[i][j]);
            break;
        }
        i++;
    }
    j++;
    }
    return segment;
}
std::pair<DoublePair,DoublePair>DefaultContour::getSegment1_(double parameter1){
std::pair<DoublePair,DoublePair> segment;
    int i=0;
    for (std::vector<double>::iterator it= coordinatesParameters_.begin().first
            ;it !=coordinatesParameters_.end().first;it++){
        if (parameter1 < *it ){
            segment=std::make_pair(coordinates_[i-1],coordinates_[i]);
            break;
        }
        i++;
    }
    return segment;
}
std::pair<DoublePair,DoublePair>DefaultContour::getSegment2_(double parameter2){
std::pair<DoublePair,DoublePair> segment;
    int i=0;
    for (std::vector<double>::iterator it= coordinatesParameters_.first.begin()
            ;it !=coordinatesParameters_.first.end();it++){
        if (parameter2 < *it ){
            segment=std::make_pair(coordinates_[i-1],coordinates_[i]);
            break;
        }
        i++;
    }
    return segment;
}

double DefaultContour2d::lowlowExtrapolate_(double parameter1, double parameter2){
    (void) parameter1, parameter2;
    return coordinates_.front().front().third; // the y-coordinate of the first element
}
double DefaultContour2d::lowhighExtrapolate_(double parameter1, double parameter2){
    (void) parameter1, parameter2;
    return coordinates_.back().front().third; // the y-coordinate of the last element
}
double DefaultContour2d::highlowExtrapolate_(double parameter1, double parameter2){
    (void) parameter1, parameter2;
    return coordinates_.front().back().third; // the y-coordinate of the last element
}
double DefaultContourd2d::highhighExtrapolate_(double parameter1, double parameter2){
    (void) parameter1, parameter2;
    return coordinates_.back().back().third; // the y-coordinate of the last element
}
double DefaultContour2d::interpolate1_(double parameter1, double parameter2, const std::tuple<TripleTuple,TripleTuple,TripleTuple> & segment){
    double x1,x2,y1,y2;
    x1=segment.front().first.first;
    y1=segment.front().first.second;
    x2=segment.front().second.first;
    y2=segment.front().second.second;
    double gradient=(y2-y1)/(x2-x1);
    return y1+(parameter-x1)*gradient;
}
double DefaultContour2d::interpolate2_(double parameter1, double parameter2, const std::tuple<TripleTuple,TripleTuple,TripleTuple> & segment){
    double x1,x2,y1,y2;
    x1=segment.back().first.first;
    y1=segment.back().first.second;
    x2=segment.back().second.first;
    y2=segment.back().second.second;
    double gradient=(y2-y1)/(x2-x1);
    return y1+(parameter-x1)*gradient;
}
double DefaultContour2d::interpolate3_(double parameter1, double parameter2, const std::tuple<TripleTuple,TripleTuple,TripleTuple> & segment){
    double x1,x2,y1,y2;
    x1=segment.first.front().first;
    y1=segment.first.front().second;
    x2=segment.second.front().first;
    y2=segment.second.front().second;
    double gradient=(y2-y1)/(x2-x1);
    return y1+(parameter-x1)*gradient;
}
double DefaultContour2d::interpolate4_(double parameter1, double parameter2, const std::tuple<TripleTuple,TripleTuple,TripleTuple> & segment){
    double x1,x2,y1,y2;
    x1=segment.first.back().first;
    y1=segment.first.back().second;
    x2=segment.second.back().first;
    y2=segment.second.back().second;
    double gradient=(y2-y1)/(x2-x1);
    return y1+(parameter-x1)*gradient;
}
double DefaultContour2d::interpolate2d_(double parameter1, double parameter2, const std::tuple<TripleTuple,TripleTuple,TripleTuple> & segment){
    double x1,x2,y1,y2,z1,z2,z3;
    x1=segment.first.first;
    y1=segment.first.second;
    z1=segment.first.third;    
    x2=segment.second.first;
    y2=segment.second.second;
    z2=segment.second.third;
    z3=segment.third.third;
    double gradient1=(z3-z1)/(x2-x1);
    double gradient2=(z2-z3)/(y2-y1);
    return z1+(parameter1-x1)*gradient1+(parameter2-y1)*gradient2;
}
