#!/bin/bash
tag=mkardaris2016/penaviation-core:0.6.1 
dataPath=/data


# Pull image if it doesn't exist
if [ -z "$(docker images -q ${tag})" ]
then
#  echo "Docker image not available. Building with tag '${tag}'"
#  sudo  docker build  -t $tag -f ./Dockerfile --memory='1g' .
   sudo mkdir /data
   sudo cp isbd.conf /data
   sudo cp navrouter.conf /data
   sudo login --username=mkardaris2016 -p 
   echo "Docker image is not available in this host. Pull it from docker Hub with tag: '${tag}'"  
   sudo pull $(tag)
fi
 

# Iridium SBD
sudo chmod  +666 /dev/ttyUSB0
# AutoPilot connected via USB
sudo chmod  +666 /dev/ttyACM0
# AutoPilot connected via serial line
sudo chmod  +666 /dev/ttyS0

# Run image container 
sudo docker run -it --rm --privileged -p 5770:5770/tcp -p 14500:14500/udp -p 14600:14600/udp \
    -e DISPLAY=$DISPLAY \
    --device=/dev/ttyUSB0:/dev/ttyUSB0 \
    --device=/dev/ttyACM0:/dev/ttyACM0 \
    -v $HOME/.Xauthority:/root/.Xauthority:rw \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    -v /data/isbd.conf:/mavlink-splitter/examples/isbd.conf:rw \
    -v /data/navrouter.conf:/navlink/navrouter.conf:rw \
    --mount type=bind,source=/data/isbd.conf,target=/mavlink-splitter/examples/isbd.conf:rw \
    --mount type=bind,source=/data/navrouter.conf,target=/navlink/navrouter.conf:rw \
    --name=penaviation-core ${tag} \
    bash -c "./mavlink-splitter/build/src/mavlink-routerd -c mavlink-splitter/examples/isbd.conf & sleep 5 && python3 ./navlink/navlink.py"  \
 
#xhost -local:*
