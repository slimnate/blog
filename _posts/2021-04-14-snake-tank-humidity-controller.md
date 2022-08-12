---
title: Project - Snake Tank Humidity Controller
date: 2021-04-14 12:00:00 -0500
categories: [Snake Tank Controller]
tags: [arduino, 3d printing, electronics, cpp]
image:
  src: /assets/img/humidifier/header-main.png
pin: true
---
As the proud owner of two beautiful ball pythons, named **Drakho** and **Nina**, I know first hand how important it is to ensure they have the proper climate control for their environment to live happy and healthy lives.

This project is designed to automate control of their humidity and lighting system.


1. TOC
{:toc}

## Goals
- Automated humidity control
- Automated light control
- Network connectivity to allow for monitoring and configuration of light and humidity settings from a web browser or phone.
- Eventually want to develop a mobile app to monitor and control these settings without needing to use a browser at all.

## Background info

![Drakoh](/assets/img/humidifier/drakho.png){: width="250" .right}
![Nina](/assets/img/humidifier/nina.png){: width="250" .right}

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

For the humidity monitoring, I chose a [DHT-22](https://amzn.to/3tBzmjA) temperature and humidity sensor combo ([DHT-11](https://amzn.to/2Pa2zmK) can also be used and is slightly cheaper, but the DHT-22 is more accurate)

For humidifier system I chose to use an [ultrasonic transducer](https://amzn.to/2QNdVO8) to create humid air, with 1 1/2 inch sump pump drain hoses and 40mm PC fans to push the humid air to each tank.

For details on how I designed the humidifier system, check out this article: [Snake Tank Pt. 1 - Humidifier System]({% post_url 2021-04-14-snake-tank-humidifier %})

![Humidifier System](/assets/img/humidifier/header-humidifier-system.png)

### Light control system
The second design objective was to create an AC outlet box that can be switched by an arduino. To achieve this, I use a standard 2-gang outlet box with two outlets and two [relays](https://www.amazon.com/gp/product/B00LW15A4W) to control each outlet separately. The relays are wired in series with the hot wire of the standard residential 120V AC line voltage inside the box.

For details on the design and build of the light control box, check out this article: [Snake Tank Pt. 2 - Light Controller System]({% post_url 2021-04-14-snake-tank-light-controller %})

![Light Control System](/assets/img/humidifier/header-light-system.png)

### Motherboard
The motherboard consists of a custom designed PCB, with external 24V power provided by the barrel jack, and JST connections for each of the peripheral components to plug into. For the microcontroller I chose an [Arduino Nano33 IoT](https://store.arduino.cc/usa/nano-33-iot) for it's built in bluetooth and wifi modules. I need a total of 6 digital I/O pins (2 input for humidity sensors, 2 output for light relays, and 2 output for humidifier control), which is more than covered by the Nano33's 13 digital I/O pins.
For details on how the the electronics hardware was designed, check out the article: [Snake Tank Pt. 3 - Motherboard]({% post_url 2021-04-14-snake-tank-motherboard %})

![Motherboard](/assets/img/humidifier/header-motherboard.png)

### Arduino Software
The embedded software that runs on the arduino is written in object oriented C++, and reads the humidity sensor data to enable/disable the humidifier system automatically depending on the humidity levels read. It communicates with a public [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol) server to retrieve the current date/time, and uses this time data to control the light box. Finally, it exposes a REST-ful (ish) web server that is used to communicate with the device from a mobile app, providing methods to access device status, and update configuration. For details on the design and implementation of the embedded, check out the article covering that: [Snake Tank Pt. 4 - Embedded Software]({% post_url 2021-04-14-snake-tank-software %})

![Software](/assets/img/humidifier/header-software.png)

### Mobile App
The final major component of this project is a mobile application that communicates with the main device hardware. This application consumes the routes provided by the embedded web server to display current system status, and provides a UI to update the humidity settings and light schedule. The mobile app was written in the [Dart language](https://dart.dev/) from Google, using the [Flutter framework](https://flutter.dev/) for cross-platform app development. For details on the design and implementation of the mobile app, check out the article covering that: [Snake Tank Pt. 5 - Mobile App]({% post_url 2021-04-14-snake-tank-mobile-app %})

![Software](/assets/img/humidifier/header-mobile-app.png)


*This project is currently still in development, and this post will be updated with future progress.*