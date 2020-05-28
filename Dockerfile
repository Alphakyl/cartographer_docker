FROM ros:melodic

# install build tools
RUN apt-get update && apt-get install -y \
	python-wstool \
	python-rosdep \
  ninja-build \
	python-catkin-tools \ 
	&& rm -rf /var/lib/apt/lists/*

# create ROS workspace and cartographer workspace
ENV ROS_WS /opt/catkin_ws/
ENV CART_WS /opt/cartographer_ws
RUN mkdir -p $ROS_WS/src

# Change working directory
WORKDIR $CART_WS

# Install cartographer and dependencies
RUN wstool init src && \
 		wstool merge -t src \
			https://raw.githubusercontent.com/googlecartographer/cartographer_ros/master/cartographer_ros.rosinstall && \
		wstool update -t src
RUN src/cartographer/scripts/install_proto3.sh && \
 		apt-get update && \
		rosdep update && \
		rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y && \
		rm -rf /var/lib/apt/lists/*

# Change working directory to source, remove and update cartographer and cartographer_ros
WORKDIR ./src
RUN rm -rf cartograph*
RUN git clone https://github.com/googlecartographer/cartographer_ros.git
RUN git clone https://github.com/googlecartographer/cartographer.git

# Change working directory and compile cartographer
WORKDIR ../

SHELL ["/bin/bash", "-c"]
RUN source "/opt/ros/melodic/setup.bash" && \
		catkin_make_isolated --install --use-ninja

# Change working directory to catkin_ws
WORKDIR $ROS_WS

ENTRYPOINT ["bash"]
