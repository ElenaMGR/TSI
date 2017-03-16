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

void random_walk::turn(bool direccion) {
	geometry_msgs::Twist msg;
   if (direccion)
      msg.angular.z = MIN_SCAN_ANGLE;
   else
	  msg.angular.z = -MIN_SCAN_ANGLE;
	commandPub.publish(msg);
}

// Process the incoming laser scan message
void random_walk::scanCallback(const sensor_msgs::LaserScan::ConstPtr& scan)
{
	bool isObstacleInFront = false;
   bool giro = false;
   int contIzq = 0, contDch = 0;

    // Find the closest range between the defined minimum and maximum angles
    int minIndex = ceil((MIN_SCAN_ANGLE - scan->angle_min) / scan->angle_increment);
    int maxIndex = floor((MAX_SCAN_ANGLE - scan->angle_min) / scan->angle_increment);
    int media = ( maxIndex - minIndex - 1) / 2;

    for (int currIndex = minIndex + 1; currIndex <= maxIndex; currIndex++) {
       if (scan->ranges[currIndex] < minDistance) {
        	 isObstacleInFront = true;
          if (currIndex < media )
            contIzq += 1;
          else
            contDch += 1;
          break;
       }
    }


    if (isObstacleInFront) {
      ROS_INFO("Giro!");
      keepMoving = false;

      if (contIzq < contDch)
        dir = true;
      else if (contDch < contIzq)
        dir = false;
      else{
        if (rand()%2==1)
           dir = true;
        else
           dir = false;
      }
    }
    else{
      keepMoving = true;
   }
}

void random_walk::startMoving(){
   ros::Rate rate(10);
   ROS_INFO("Start moving");

   // Keep spinning loop until user presses Ctrl+C or the robot got too close to an obstacle
   while (ros::ok()) {
      while (ros::ok() && keepMoving){
         moveForward();
         ros::spinOnce(); // Need to call this function often to allow ROS to process incoming messages
         rate.sleep();
      }
      while (ros::ok() && !keepMoving){
         turn(dir);
         //keepMoving = true;
         ros::spinOnce(); // Need to call this function often to allow ROS to process incoming messages
         rate.sleep();
      }
   }
}
