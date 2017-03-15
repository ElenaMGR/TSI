# Install script for directory: /home/elena/GradoInformatica/Tercero/2Cuatrimestre/TSI/Practicas/random_walk/src/random_walk

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/elena/GradoInformatica/Tercero/2Cuatrimestre/TSI/Practicas/random_walk/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/elena/GradoInformatica/Tercero/2Cuatrimestre/TSI/Practicas/random_walk/build/random_walk/catkin_generated/installspace/random_walk.pc")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/random_walk/cmake" TYPE FILE FILES
    "/home/elena/GradoInformatica/Tercero/2Cuatrimestre/TSI/Practicas/random_walk/build/random_walk/catkin_generated/installspace/random_walkConfig.cmake"
    "/home/elena/GradoInformatica/Tercero/2Cuatrimestre/TSI/Practicas/random_walk/build/random_walk/catkin_generated/installspace/random_walkConfig-version.cmake"
    )
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/random_walk" TYPE FILE FILES "/home/elena/GradoInformatica/Tercero/2Cuatrimestre/TSI/Practicas/random_walk/src/random_walk/package.xml")
endif()

