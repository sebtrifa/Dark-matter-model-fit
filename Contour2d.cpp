include "Contour2d.h"
Contour2d::Contour2d(std::pair<TripleTuple> coordinates):
    coordinates_(coordinates)
{
// intentionally empty
//     // cannot invoke getCoordinatesParameters, since in depends on get_point_parameters
//
}

double Contour2d::getContourValue(double parameter1, double parameter2){
    if (parameter1 <= coordinatesParameters_.front().first){
       if(parameter2 <= coordinatesParameters_.first.front()){
        return lowlowExtrapolate_(parameter1, parameter2);
    }
    else if (coordinatesParameters_.first.front() < parameter2 <coordinatesParameters_.first.back())
    {
     std::tuple< TripleTuple,TripleTuple,TripleTuple> segment = getSegment2_(parameter2);
     return interpolate1_(parameter1, parameter2, segment);
    }
   else
    {
     return lowhighExtrapolate_(parameter1, parameter2)
    }
    }
    else if (parameter1 <coordinatesParameters_.back().first){
     if(parameter2 <= coordinatesParameters_.first.front()){
     std::tuple< TripleTuple,TripleTuple,TripleTuple> segment = getSegment1_(parameter1);
     return interpolate3_(parameter1, parameter2, segment);
     }
     else if(coordinatesParameters_.first.front() < parameter2 <coordinatesParameters_.first.back())
    {    
  std::tuple< TripleTuple,TripleTuple,TripleTuple > segment = getSegment_(parameter1,parameter2);
        return interpolate2d_(parameter1, parameter2, segment);
    }
    else {
        std::tuple< TripleTuple,TripleTuple,TripleTuple> segment = getSegment2_(parameter2);
        return interpolate4_(parameter1, parameter2, segment);
    }
    }
    else{
     if(parameter2 <= coordinatesParameters_.first.front()){
    return highlowExtrapolate_(parameter1, parameter2)
    }
    else if(coordinatesParameters_.first.front() < parameter2 <coordinatesParameters_.first.back()){
    std::tuple< TripleTuple,TripleTuple,TripleTuple> segment = getSegment1_(parameter1);
    return interpolate2_(parameter1, parameter2, segment);
    }  
    else{
    return highhighExtrapolate_(parameter1, parameter2)
    }
    }

}

double Contour2d::getContourValue(double parameter2){
    if (parameter2 <= coordinatesParameters_.front()){
        return lowExtrapolate_(parameter2);
    }
    else if (parameter2 <coordinatesParameters_.back()){
        std::pair< DoublePair,DoublePair > segment = getSegment_(parameter2);
        return interpolate_(parameter2, segment);
    }
    else {
        return highExtrapolate_(parameter2);
    }
}


double Contour2d::getPointParameter(const std::vector<double> & pointCoordinatesVec){
if (pointCoordinatesVec.size() == 3){
        TriplePair pointCoordinates(pointCoordinatesVec[0], pointCoordinatesVec[1],pointCoordinatesVec[2]);
        return getPointParameter_(pointCoordinates);
    }
    else{
:endl;
        std::cout << "       " << pointCoordinatesVec.size() << " were given" << std::endl;
        return -1e9;
    }
}
double Contour2d::getPointParameter(const TriplePair & point){
    return getPointParameter_(point);
}
double Contour2d::getPointValue(const std::vector<double> & pointCoordinatesVec){
    if (pointCoordinatesVec.size() == 3){
        DoublePair pointCoordinates(pointCoordinatesVec[0], pointCoordinatesVec[1],pointCoordinatesVec[2]);
return getPointValue_(pointCoordinates);
    }
    else{
   //FIXME: maybe have to throw something.. this may be better error handling
std::cout << "ERROR: getPointValue takes two doubles in a vector " << std::endl;
        std::cout << "       " << pointCoordinatesVec.size() << " were given" << std::endl;
        return -1e9;
    }
}
double Contour2d::getPointValue(const TriplePair & point){
    return getPointValue_(point);
}
std::vector<double> Contour::getCoordinatesParameters(){
    std::vector<double> coordinatesParameters;
    for (std::vector<DoublePair>::iterator it = coordinates_.begin(); it!=coordinates_.end(); it++){
        coordinatesParameters.push_back(getPointParameter_(*it));
    }
    return coordinatesParameters;
}
