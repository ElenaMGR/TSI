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
    msg.angular.z = 0;
    commandPub.publish(msg);
}

void random_walk::turn(bool direccion) {
	geometry_msgs::Twist msg;
   msg.linear.x = 0;
   if (!direccion)
      msg.angular.z = FORWARD_SPEED;
   else
	  msg.angular.z = -FORWARD_SPEED;
	commandPub.publish(msg);
}

// Process the incoming laser scan message
void random_walk::scanCallback(const sensor_msgs::LaserScan::ConstPtr& scan)
{
   isObstacleInFront = false;
    // Find the closest range between the defined minimum and maximum angles
    int minIndex = ceil((MIN_SCAN_ANGLE - scan->angle_min) / scan->angle_increment);
    int maxIndex = floor((MAX_SCAN_ANGLE - scan->angle_min) / scan->angle_increment);
    int media = ( maxIndex - minIndex - 1) / 2;

    for (int currIndex = minIndex + 1; currIndex <= maxIndex; currIndex++) {
       if (scan->ranges[currIndex] < minDistance) {
        	 isObstacleInFront = true;
          break;
       }
    }

    double minimo = 10;
    for (int currIndex = 0; currIndex <= scan->ranges.size()/3; currIndex++) {
       if (scan->ranges[currIndex] < minimo) {
        	 minimo = scan->ranges[currIndex];
       }
    }

    minDch = minimo;

    minimo = 10;
    for (int currIndex = scan->ranges.size()*2/3; currIndex <= scan->ranges.size()-1; currIndex++) {
       if (scan->ranges[currIndex] < minimo) {
        	 minimo = scan->ranges[currIndex];
       }
    }

    minIzq = minimo;


}

void random_walk::startMoving(){
   ros::Rate rate(10);
   ROS_INFO("Start moving");

   // Keep spinning loop until user presses Ctrl+C or the robot got too close to an obstacle
   while (ros::ok()) {
      if (turnTime > 0){
         turnTime--;
         ROS_INFO("Cuenta %d", turnTime);
      }else if (!isObstacleInFront){
         moveForward();
         ROS_INFO("Avanzo");
      }else if(minIzq>minDch){
         turn(false);
         turnTime = 10;
      }else{
         turn(true);
         turnTime = 10;
      }

      ros::spinOnce(); // Need to call this function often to allow ROS to process incoming messages
      rate.sleep();
   }
}
