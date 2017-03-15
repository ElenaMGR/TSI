/*
 * run_random_walk.cpp
 * Author: Elena María Gómez Ríos
 */

#include "../include/random_walk.h"

int main(int argc, char **argv) {
   // Initiate new ROS node named "stopper"
   ros::init(argc, argv, "random_walk");

   //Distancia mínima a un obstaculo
   float minDistance;
   if (argc==2)
      minDistance = atof(argv[1]);
   else
      minDistance = 0.8;


   // Create new stopper object
   random_walk rw(minDistance);

   // Start the movement
   rw.startMoving();

   return 0;
};
