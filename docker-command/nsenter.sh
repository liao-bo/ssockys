#!/bin/bash


sudo nsenter --target `docker inspect --format {{.State.Pid}} $1` --mount --uts --ipc --net --pid bash