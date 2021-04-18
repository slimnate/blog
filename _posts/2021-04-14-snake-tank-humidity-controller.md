---
title: Snake Tank Humidity Controller
categories: [Projects]
tags: [arduino, 3d printing, circuits, c++]
pin: true
---
1. TOC
{:toc}


As the proud owner of two beautiful ball pythons, named **Drakho** and **Nina**, I know first hand how important it is to ensure they have the proper climate control to live happy and healthy lives. 

This project is designed to automate control of their humidity and lighting.

## Goals
- Automated humidity control
- Automated light control
- Network connectivity to allow for monitoring and configuration of light and humidity settings from a web browser or phone.
- Eventually want to develop a mobile app to monitor and control these settings without needing to use a browser at all.

## Background info
Since ball pythons are native to Africa, they have very different environmental requirements from my home state of Kansas:
- Humidity
  - Ball pythons naturally live in humid environments, and require a constant 80%-95% humidity.
  - This is especially true during shedding time, to allow them to easily release from their shed skin in one piece.
- Heat
  - Snakes are cold-blooded animals, and therefore require external heat sources to maintain their ideal body temperature of about 95°F
  - This is currently controlled by a heat pad under the tank, and various heat lamps above.
- Light
  - Snakes require different kinds of heat lamps during day/night.
  - White lamps during the day time, and red lamps during the night time.
  - This is currently controlled with a couple light timers that I purchased, but those must be physically manipulated to change their timing, and I want to be able to simulate the light schedule in their homeland, including changes of the day/night duration during different seasons.

## Design

There are several main sub-components of the project that each need to be designed:
- Humidifier system
- Light controller systems
- Arduino and control software

### Humidifier system
The first major design goal was to determine the best method for monitoring and providing humidity to the tanks.

For the humidity monitoring, I chose a [DHT-22](https://www.amazon.com/gp/product/B07XBVR532) temperature and humidity sensor combo (DHT-11 can also be used and is slightly cheaper, but the DHT-22 is more accurate)

For humidifier system I chose to use an [ultrasonic transducer](https://www.amazon.com/gp/product/B08GQT43W7) to create humid air, with 1 1/2 inch sump pump drain hoses and 40mm PC fans to push the humid air to each tank.

### Light control system
The second design objective was to create an AC outlet box that can be switched by an arduino. To achieve this, I use a standard 2-gang outlet box with two outlets and two [relays](https://www.amazon.com/gp/product/B00LW15A4W) to control each outlet separately. The relays are wired in series with the hot wire of the standard residential 120V AC line voltage inside the box.

### Arduino and control system
For the microcontroller I chose an [Arduino Nano33 IoT](https://store.arduino.cc/usa/nano-33-iot) for it's built in bluetooth and wifi modules. I need a total of 6 digital I/O pins (2 input for humidity sensors, 2 output for light relays, and 2 output for humidifier control), which is more than covered by the Nano33's 13 digital I/O pins.


*This project is currently still in development, and this post will be updated with future progress.*