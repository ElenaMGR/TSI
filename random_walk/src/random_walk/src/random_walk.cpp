/*
 * random_walk.cpp
 * Author: Elena María Gómez Ríos
 */

#include "../include/random_walk.h"
#include "geometry_msgs/Twist.h"

random_walk::random_walk(float minDistance)
{
    keepMoving = true;
    this->minDistance = minDistance;

    // Advertise a new publisher for the robot's velocity command topic
    commandPub = node.advertise<geometry_msgs::Twist>("/cmd_vel_mux/input/teleop", 10);

    // Subscribe to the simulated robot's laser scan topic
    laserSub = node.subscribe("scan", 1, &random_walk::scanCallback, this);
}

// Send a velocity command
void random_walk::moveForward() {
    geometry_msgs::Twist msg; // The default constructor will set all commands to 0
    msg.linear.x = FORWARD_SPEED;
    commandPub.publish(msg);
}

void random_walk::turn() {
	geometry_msgs::Twist msg;
	msg.angular.z = MIN_SCAN_ANGLE;
	commandPub.publish(msg);
}

// Process the incoming laser scan message
void random_walk::scanCallback(const sensor_msgs::LaserScan::ConstPtr& scan)
{
	bool isObstacleInFront = false;

    // Find the closest range between the defined minimum and maximum angles
    int minIndex = ceil((MIN_SCAN_ANGLE - scan->angle_min) / scan->angle_increment);
    int maxIndex = floor((MAX_SCAN_ANGLE - scan->angle_min) / scan->angle_increment);

    for (int currIndex = minIndex + 1; currIndex <= maxIndex; currIndex++) {
        if (scan->ranges[currIndex] < minDistance) {
        	isObstacleInFront = true;
            break;
        }
    }

    if (isObstacleInFront) {
        ROS_INFO("Stop!");
        keepMoving = false;
    }
}

void random_walk::startMoving(){
   ros::Rate rate(10);
   ROS_INFO("Start moving");

   // Keep spinning loop until user presses Ctrl+C or the robot got too close to an obstacle
   while (ros::ok()) {
      if (keepMoving)
         moveForward();
      else{
         turn();
         keepMoving = true;
      }
      ros::spinOnce(); // Need to call this function often to allow ROS to process incoming messages
      rate.sleep();
   }
}
