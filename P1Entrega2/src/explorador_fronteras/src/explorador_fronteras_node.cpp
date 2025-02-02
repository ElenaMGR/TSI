#include <ros/ros.h>
#include <move_base_msgs/MoveBaseAction.h>
#include <actionlib/client/simple_action_client.h>
//gestion de costmaps
#include "tf/transform_listener.h"
#include <tf/transform_datatypes.h>
#include <boost/thread.hpp>
#include "explorador_fronteras_node.h"
#include <limits>
#include <iostream>
#include <fstream>
#include <time.h>

typedef actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction> MoveBaseClient;


//imprime en pantalla el contendio de un mapa
void printMapa (std::vector< std::vector<int> > mapa) {
//lo escribe en la orientación correcta, primero escribe las filas superiores ....
     for (int x=0 ;x < mapa[0].size(); x++)
          for (int y= mapa.size()-1 ; y >=0 ;y--){
              std::cout << (int) mapa[y][x] << " ";
            }
        }
void FrontierExplorer::printMapToFile () {

   //Escribe el mapa en el fichero "grid.txt"
    std::ofstream gridFile;
    gridFile.open("grid.txt");

     for (int x=0 ;x < theGlobalCm[0].size(); x++) {
          for (int y= theGlobalCm.size()-1 ; y >=0 ;y--){
              gridFile << (int) theGlobalCm[y][x] << " ";
            }
            gridFile << std::endl;
        }
        gridFile.close();
}

FrontierExplorer::FrontierExplorer()
{
    //Inicializa el explorador de fronteras.
    mapIsEmpty = true;
    posGoal.x = posGoal.y = 0;  //Posición del objetivo
    nodoPosicionRobot.x = nodoPosicionRobot.y = 0;      //Posición actual
    yaw =0;     //Angulo (en radianes) de orientación del robot
    v_angular = v_lineal = 0.0; //velocidad angular
	// Advertise a new publisher for the simulated robot's velocity command topic
	commandPub = node.advertise<geometry_msgs::Twist>("cmd_vel", 10);
    //Publicador del objetivo en rviz.
    marker_pubobjetivo = node.advertise<visualization_msgs::Marker>("visualizacion_objetivo", 1);
   //Publicador de los nodos de frontera para visuoalizarlos en rviz
    marker_pub = node.advertise<visualization_msgs::Marker>("visualization_marker", 1000);
	//Se subscribe a la posición publicada por la odometría
    odomSub =  node.subscribe("odom", 100, &FrontierExplorer::odomCallBack, this);
    //Se subscribe al mapa publicado por gmapping
    mapSub = node.subscribe("map", 100, &FrontierExplorer::getmapCallBack, this);
}

void FrontierExplorer::gira360(){
    geometry_msgs::Twist msg;
    ros::Time end = ros::Time::now() + ros::Duration(16);

    while(ros::Time::now() < end){
      msg.angular.z = V_ANGULAR_CTE;
      commandPub.publish(msg);
    }
}

void FrontierExplorer::getmapCallBack(const nav_msgs::OccupancyGrid::ConstPtr& msg){
   //callback para obtener el mapa.
   mapIsEmpty = true; //asumimos que el mapa está vacío antes de recibirlo
   cmGlobal = *msg;   //guardamos en la variable cmGlobal el mensaje recibido para
                       // disponer del mensaje en nuestro programa
   //redimensiona el  mapa segun las dimensiones del mapa recibido
   theGlobalCm.resize(cmGlobal.info.height);//resize al numero de filas
   theGlobalCmModify.resize(cmGlobal.info.height);
   for (int y = 0; y < cmGlobal.info.height; y++){
      theGlobalCm[y].resize(cmGlobal.info.width);
      theGlobalCmModify[y].resize(cmGlobal.info.width);
   }

   //inicializo el vector de bool a false
   for (int i = 0; i < cmGlobal.info.height; i++)
      for (int j = 0; j < cmGlobal.info.width; j++)
         theGlobalCmModify[i][j]=false;

   //copia el mapa del mensaje en el mapa del explorador de fronteras
   //informa en mapEmpty si hay celdas con información.
   int currCell = 0;
   for (int y=0; y < cmGlobal.info.height; y ++)
      for (int x = 0; x < cmGlobal.info.width; x++){
         if (theGlobalCmModify[y][x]==false){
            theGlobalCm[y][x] =  cmGlobal.data[currCell];
            if (theGlobalCm[y][x] != -1) mapIsEmpty = false;
            if (theGlobalCm[y][x] == 100) rellenaObstaculos(x,y);
         }

         currCell++;
      }

   //cmGlobal.header.seq = msg->header.seq;
   //cmGlobal.header.stamp = msg->header.stamp;
   //cmGlobal.header.frame_id = msg->header.frame_id;
   //
   //cmGlobal.info.map_load_time = msg->info.map_load_time ;
   //cmGlobal.info.resolution = msg->info.resolution;
   //cmGlobal.info.width = msg->info.width;
   //cmGlobal.info.height = msg->info.height;
   //
   //cmGlobal.info.origin.position.x = msg->info.origin.position.x;
   //cmGlobal.info.origin.position.y = msg->info.origin.position.y;
   //cmGlobal.info.origin.position.z = msg->info.origin.position.z;
   //
   //cmGlobal.info.origin.orientation.x = msg->info.origin.orientation.x;
   //cmGlobal.info.origin.orientation.y = msg->info.origin.orientation.y;
   //cmGlobal.info.origin.orientation.z = msg->info.origin.orientation.z;
   //cmGlobal.info.origin.orientation.w = msg->info.origin.orientation.w;
   //
}
void FrontierExplorer::rellenaObstaculos(int cell_x, int cell_y){
   for (int i = cell_x - 10; i<= cell_x + 10; i++)
      for (int j = cell_y - 10; j<= cell_y + 10; j++){
         if (i!=cell_x && j!=cell_y)
            if ( i>=0 && j < cmGlobal.info.height && j>=0 && i < cmGlobal.info.width){
               theGlobalCm[j][i]=100;
               theGlobalCmModify[j][i]=true;
            }
      }
}


void FrontierExplorer::odomCallBack(const nav_msgs::Odometry::ConstPtr& msg)
{
    //obtengo la posición. y la guardo en el dato miembro del objeto FrontierExplorer
    nodoPosicionRobot.x=msg->pose.pose.position.x;
    nodoPosicionRobot.y=msg->pose.pose.position.y;
    //también la guardo en FrontierExplorer::odometria
    odometria.pose.pose.position.x = nodoPosicionRobot.x;
    odometria.pose.pose.position.y = nodoPosicionRobot.y;
    //get Quaternion anglular information
    double x=msg->pose.pose.orientation.x;
    double y=msg->pose.pose.orientation.y;
    double z=msg->pose.pose.orientation.z;
    double w=msg->pose.pose.orientation.w;
    //la guardo en la odometría
    odometria.pose.pose.orientation.x = x;
    odometria.pose.pose.orientation.y = y;
    odometria.pose.pose.orientation.z = z;
    odometria.pose.pose.orientation.w = w;

    //convertir to pitch,roll, yaw
    //consultado en http://answers.ros.org/question/50113/transform-quaternion/
    //guardo el yaw en FrontierExplorer::yaw
    yaw=atan2(2*(y*x+w*z),w*w+x*x-y*y-z*z);
};

bool FrontierExplorer::someNeighbourIsUnknown(int cell_x,int cell_y){
   //cell_x representa la abcisa de una celda dada del mapa.
   //cell_y representa la ordenada.
   //Devuelve true si hay alguna casilla vecina a la celda dada que es desconocida
   for (int x = -1; x<= 1; x++)
      for (int y = -1; y <= 1; y ++)
         if ((cell_x+x >=0) && (cell_x+x < cmGlobal.info.width) &&
            (cell_y+y >=0) && (cell_y+y < cmGlobal.info.height))
            if (theGlobalCm[cell_y+y][cell_x+x] == -1)
               return true;
            return false;
}

bool FrontierExplorer::someNeighbourIsObstacle(int cell_x,int cell_y){

    //cell_x representa la abcisa de una celda dada del mapa.
    //cell_y representa la ordenada.
    //Devuelve true si hay alguna casilla vecina a la celda dada que es un obstáculo
    return true;

}


//calculo de la distancia (sobrecargada) entre dos nodos de frontera o entre dos reales (más abajo)
double distancia(nodeOfFrontier &n1, nodeOfFrontier &n2) {

     return sqrt((pow(n1.x - n2.x,2))+pow(n1.y - n2.y, 2));
}

double distancia(double c1_x, double c1_y, double c2_x, double c2_y) {
    return sqrt((pow(c1_x - c2_x,2))+pow(c1_y - c2_y, 2));

}


void FrontierExplorer::eraseFrontier(double px, double py) {

   //borra nodos de la frontera a una distancia de dos metros de la posición (px,py)
   TipoFrontera::iterator it=frontera.begin();
   while (it!=frontera.end()) {
      if (distancia(px,py, it->x, it->y) <= 2)
         frontera.erase(it);
      else it++;
   }
}


void FrontierExplorer::eraseFrontierNode(double px, double py) {

   //borra el nodo de la frontera de la posición (px,py)
   TipoFrontera::iterator it=frontera.begin();
   while (it!=frontera.end()) {
      if (it->x==px && it->y==py)
         frontera.erase(it);
      else it++;
   }
}




void FrontierExplorer::labelFrontierNodes(){
   frontera.clear();
   nodeOfFrontier nodo;
   //La frontera es un vector de pares de coordenadas (de tipo TipoFrontera)
   //Insertar en frontera los puntos, en coordenadas del mundo, que tienen algún vecino desconocido.
   for (int j=0; j< cmGlobal.info.height; j++)
      for (int i=0; i< cmGlobal.info.width; i++){
         if (theGlobalCm[j][i]==0)
            if (someNeighbourIsUnknown(i,j)){
               nodo.x = (i*cmGlobal.info.resolution) + cmGlobal.info.origin.position.x;
               nodo.y = (j*cmGlobal.info.resolution) + cmGlobal.info.origin.position.y;
               frontera.push_back(nodo);
            }
      }

   eraseFrontier(nodoPosicionRobot.x,nodoPosicionRobot.y);
}



void FrontierExplorer::selectNode(nodeOfFrontier &selectednode){
   if (frontera.size()>0){
      eraseFrontierNode(nodoBorrar.x, nodoBorrar.y);

      selectednode = frontera[0];
      double dist = distancia(nodoPosicionRobot, frontera[0]);

      for (int i=1; i< frontera.size(); i++){
         if (distancia(nodoPosicionRobot, frontera[i]) < dist){
            dist = distancia(nodoPosicionRobot, frontera[i]);
            selectednode = frontera[i];
         }
      }
   }
   else{
      terminado = true;
   }
}



int main(int argc, char** argv) {

  ros::init(argc,argv, "frontier_explorer_node");

  // create the action client
  MoveBaseClient ac("move_base", true);
  // Wait 60 seconds for the action server to become available
  ROS_INFO("Waiting for the move_base action server");
  ac.waitForServer(ros::Duration(60));
  ROS_INFO("Connected to move base server");

 //inicializa el explorador
  FrontierExplorer explorador;
  //inicializa la visualización de la frontera
  explorador.inicializaMarkers("frontera", 0,0.0f,1.0f,0.0f);
  //inicializa la visualización del objetivo seleccionado.
  explorador.inicializaMarkerSphere("objetivo",0, 0.0, 0.0, 1.0);
  //hacemos que se gestionen las callbacks hasta que el mapa tenga información
  ROS_INFO("Esperando a que mapa REinicie y tenga información");
  while (explorador.mapIsEmpty)
    ros::spinOnce();
  //ROS_INFO("YA SE QUE EL MAPA NO ESTÁ VACÍO %d filas, %d columnas", explorador.cmGlobal.info.height, explorador.cmGlobal.info.width);
  ros::Rate frecuencia(0.2);

  nodeOfFrontier node;
  move_base_msgs::MoveBaseGoal goal;
  goal.target_pose.header.frame_id = "map";
  goal.target_pose.header.stamp = ros::Time::now();
  bool bloqueo = false;
  bool terminado = false;

  while (ros::ok() && !terminado) {
     std::cout<<"Bloqueo: "<<bloqueo<<std::endl;
     if (!bloqueo){
        explorador.gira360();
        std::cout<<"Giro"<<std::endl;
     }

     ros::spinOnce();
     //printMapa(explorador.theGlobalCm);
     ROS_INFO("Escribiendo mapa en fichero de texto.");
     explorador.printMapToFile();
     ROS_INFO("Posicion actual del robot (%f %f %f)",explorador.nodoPosicionRobot.x,explorador.nodoPosicionRobot.y,explorador.yaw);

     explorador.labelFrontierNodes();
     explorador.visualizaLista(explorador.frontera);
     explorador.selectNode(node);
     explorador.visualizaObjetivo(node.x,node.y);

     // Send a goal to move_base
     goal.target_pose.pose.position.x = node.x;
     goal.target_pose.pose.position.y = node.y;

     // Convert the Euler angle to quaternion
     double radians = explorador.yaw * (M_PI/180);
     tf::Quaternion quaternion;
     quaternion = tf::createQuaternionFromYaw(radians);
     geometry_msgs::Quaternion qMsg;
     tf::quaternionTFToMsg(quaternion, qMsg);
     goal.target_pose.pose.orientation = qMsg;

     // Send the goal command
     ROS_INFO("Sending robot to: x = %f, y = %f, theta = %f", node.x, node.y, explorador.yaw);
     ac.sendGoal(goal);

     // Wait for the action to return
     ac.waitForResult();

     if (ac.getState() == actionlib::SimpleClientGoalState::SUCCEEDED){
        ROS_INFO("You have reached the goal!");
        bloqueo = false;
     }
     else{
        ROS_INFO("The base failed for some reason");
        //Borro nodo objetivo y selecciono otro
        explorador.eraseFrontierNode(node.x,node.y);
        explorador.nodoBorrar = node;
        bloqueo = true;
     }

     ROS_INFO("Esperando a finalizar el bucle");
     frecuencia.sleep();

    }
  // shutdown the node and join the thread back before exiting
  ros::shutdown();


  return 0;

}



  /********VISUALIZAR FRONTERA *************************/

void FrontierExplorer::inicializaMarkerSphere(std::string ns, int id, float r, float g, float b) {
        marker_objetivo.header.frame_id = "map";
        marker_objetivo.header.stamp =  ros::Time::now();
        marker_objetivo.ns = ns;

        marker_objetivo.action = visualization_msgs::Marker::ADD; //la otra es DELETE
        marker_objetivo.pose.orientation.w = 0.0;

        marker_objetivo.id = id;

        marker_objetivo.type = visualization_msgs::Marker::SPHERE;

        // POINTS markers use x and y scale for width/height respectively
        marker_objetivo.scale.x = 0.2;//cmGlobal.info.resolution;
        marker_objetivo.scale.y = 0.2;//cmGlobal.info.resolution;

        // Points are green
        marker_objetivo.color.g = g;
        marker_objetivo.color.r = r;
        marker_objetivo.color.b = b;
        marker_objetivo.color.a = 1.0;
}

void FrontierExplorer::inicializaMarkers(std::string ns, int id, float r, float g, float b) {
        markers_frontera.header.frame_id = "map";//cmGlobal.header.frame_id.c_str();//getGlobalFrameID().c_str();
        markers_frontera.header.stamp =  ros::Time::now();
        markers_frontera.ns = ns;

        markers_frontera.action = visualization_msgs::Marker::ADD; //la otra es DELETE
        markers_frontera.pose.orientation.w = 0.0;

        markers_frontera.id = id;

        markers_frontera.type = visualization_msgs::Marker::POINTS;

        // POINTS markers use x and y scale for width/height respectively
        markers_frontera.scale.x = 0.05;//cmGlobal.info.resolution;
        markers_frontera.scale.y = 0.05;//cmGlobal.info.resolution;

        // Points are green
        markers_frontera.color.g = g;
        markers_frontera.color.r = r;
        markers_frontera.color.b = b;
        markers_frontera.color.a = 1.0;
}


void FrontierExplorer::visualizaObjetivo(double x, double y) {
        //PINTO: cpstart.x, cpstart.y, scale == costmap_->getResolution
        limpiaMarkerObjetivo();
        marker_objetivo.pose.position.x = x;
        marker_objetivo.pose.position.y = y;

        marker_pubobjetivo.publish(marker_objetivo); //lo publico
        //points.points.pop_back(); //quito el punto de la lista de puntos, lo borro con DELETE cuando lo saque de abiertos.
        }



 void FrontierExplorer::visualizaLista(TipoFrontera lista) {

    limpiaMarkers();
    markers_frontera.points.erase(markers_frontera.points.begin(), markers_frontera.points.end());
     for(TipoFrontera::iterator it = lista.begin(); it != lista.end(); ++it)
       {

         double wpose_x = it->x;
         double wpose_y = it->y;
         //PINTO: cpstart.x, cpstart.y, scale == costmap_->getResolution
         geometry_msgs::Point p;
         p.x = wpose_x;
         p.y = wpose_y;
         p.z = 0; //¿?

         markers_frontera.points.push_back(p);
        }
      marker_pub.publish(markers_frontera);
 //quitar neighborCells de points .popback
 }

 void FrontierExplorer::limpiaMarkerObjetivo() {
    marker_objetivo.action = visualization_msgs::Marker::DELETE;
    marker_pubobjetivo.publish(marker_objetivo);
    marker_objetivo.action = visualization_msgs::Marker::ADD;

 }
 void FrontierExplorer::limpiaMarkers() {
    if (!markers_frontera.points.empty()){
        markers_frontera.action = visualization_msgs::Marker::DELETE;
        marker_pub.publish(markers_frontera);
        markers_frontera.action = visualization_msgs::Marker::ADD;
    }
    markers_frontera.points.clear();


 }
