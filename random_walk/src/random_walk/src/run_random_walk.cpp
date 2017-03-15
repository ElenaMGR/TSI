/*
 * run_random_walk.cpp
 * Author: Elena María Gómez Ríos
 */

#include "../include/random_walk.h"

int main(int argc, char **argv) {
    // Initiate new ROS node named "stopper"
    ros::init(argc, argv, "random_walk");

    // Create new stopper object
    random_walk rw;

    // Start the movement
    rw.startMoving();

    return 0;
};
