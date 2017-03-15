/*
 * random_walk.h
 * Author: Elena María Gómez Ríos
 */

#ifndef random_walk_H_
#define random_walk_H_
#include "ros/ros.h"
#include "sensor_msgs/LaserScan.h"

class random_walk {
public:
    // Tunable parameters
    const static double FORWARD_SPEED = 0.3;
    const static double MIN_SCAN_ANGLE = -30.0/180*M_PI;
    const static double MAX_SCAN_ANGLE = +30.0/180*M_PI;
    const static float MIN_DIST_FROM_OBSTACLE = 0.8; // Should be smaller than sensor_msgs::LaserScan::range_max

    random_walk();
    void startMoving();

private:
    ros::NodeHandle node;
    ros::Publisher commandPub; // Publisher to the robot's velocity command topic
    ros::Subscriber laserSub; // Subscriber to the robot's laser scan topic
    bool keepMoving; // Indicates whether the robot should continue moving

    void moveForward();
    void scanCallback(const sensor_msgs::LaserScan::ConstPtr& scan);
};

#endif /* random_walk_H_ */
