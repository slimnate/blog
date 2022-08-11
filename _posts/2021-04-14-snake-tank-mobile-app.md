---
title: Snake Tank Pt. 5 - Mobile App
categories: [Snake Tank Controller]
tags: [arduino, programming, cpp]
mermaid: true # enable mermaid charts
pin: false
image: # article header image
  src: /assets/img/
---

This article covers the design and implementation of the arduino software for my [Snake Tank Humidifier]({% post_url 2021-04-14-snake-tank-humidity-controller %}) project.

1. TOC
{:toc}

# What + Why?
The final major component of the [Snake Tank Humidifier]({% post_url 2021-04-14-snake-tank-humidity-controller %}) project is the software, which is responsible for controlling all of the electronics sub-systems and providing remote control of the system with network connectivity

## Goals/Requirements
When designing the software for this project I wanted to ensure that the system could be monitored and updated remotely over the network, eliminating the need to change settings with code updates, and allowing for remote monitoring of the system status without a serial connection to a computer. In order to implement this functionality, there will be two separate code bases; one that runs on the arduino, and one for the mobile monitoring and control app.

#### Arduino App
The arduino app consists of a few main components that control the electronics 
- Two separate outlets connected to AC line voltage, one for day and one for night.
- Each outlet needs two plugs (one for each tank)
- Each outlet needs to be able to be independently switched off/on by an arduino microcontroller.

#### Mobile App
- Two separate outlets connected to AC line voltage, one for day and one for night.
- Each outlet needs two plugs (one for each tank)
- Each outlet needs to be able to be independently switched off/on by an arduino microcontroller.

## Background

# How?

## On stock vs custom light control
I want to discuss a little more in depth my reasoning for building a custom switchable outlet box, rather than using one of the many existing out-of-the box day/night timer setups available online and in pet shops everywhere. The timer I currently use before designing this system works by having a dial similar to that on a wind-up kitchen timer, that completes one rotation every 24 hours. This dial has a bunch of tabs representing equal portions of that rotation that can be pulled out or pushed in to control whether the day or night light will be turned on during the period of time when the arrow is in that section. Each of these sections control 30 minute increments, the timers are pretty easy to install and configure, and they work pretty reliably in my experience.

So why would I go through the trouble of designing my own light controller? Well, for one, those timers are static and have to be changed manually to adjust for seasonal lighting differences, daylight savings time, etc. They are also basically a flip flop switch, meaning that at any given time, one light will be on and the other off; there is no point at which they can be both off or on simulataneously. With my system, I should have the ability to either blend the cycle switches together, or leave a period of no lighting in between the day/night switches.

However, my main purpose in building a custom system is to have dynamic control of the lighting schedule: To replicate the lighting in the snakes native territory, and to be able to alter the lighting schedule according to the season. This will have the added benefit of having timing controlled by syncing to an internet time server, rather than being a relative timer that stops and gets out of sync anytime it is unplugged or loses power for any reason.

## Supplies

So the basic design is a custom outlet box with two separate outlets, each switched by it's own 5V controlled relay. Below are a list of all the required tools and components:

**Parts:**
- 1 x [2 Gang outlet box](https://amzn.to/3avaEKp)
- 2 x [duplex receptacle outlets](https://amzn.to/3tGOpso)
- 1 x [matching outlet cover](https://amzn.to/32B9sR9)
- 2 x [5V relays](https://amzn.to/3auTcp3) with switching capacity >= 250V/10A AC current
- 1 x 3-prong AC power cord - you can buy something like [this](https://amzn.to/3nhqWM4) with pre-stripped ends, or use any random 3-prong power cord, like [this](https://amzn.to/2Pbm3Y9) or an old appliance power cable
- 16-[18 AWG wire](https://amzn.to/3av1s8M) for line voltage (I harvested this off the end of my power cord, 1 1/2 feet or so should be plenty to wire up 2 outlets)
- [22 AWG wire](https://amzn.to/32BTeHw) for the 5V DC relay control lines

**Tools:**
- [JST connectors + crimpers](https://amzn.to/3tHIhQv)
- [Wire strippers](https://amzn.to/3sFHGNV)
- [Hot glue gun](https://amzn.to/3dE4klC)
- [Drill and bit set](https://amzn.to/3dD5zRW) one with 1/4 in, and one with size matching your power cable diameter.
- [Screwdrivers](https://amzn.to/3tGSxbS)
- [Multimeter]()/Continuity Tester

## Prepping the gang box
The first step is to gather components and prepare the gang box for wiring. We need one hole for the main power cable, and two more for each of the relays control wires

#### Power cable hole
Drill one hole in the side of the gang box with the same diameter as your chosen power cable, making sure the cable fits snugly, reaming the hole slightly larger with the same bit if needed.
#### Control wires hole
Drill two 1/4 in holes on the opposite side of the gang box for the relay control wires. Each relay will have three 22AWG wires for it's control, so make sure that you can comfortably fit 3 wires through each of these holes without damaging them.

## Wiring components
Once the gang box is prepared, it's time to start wiring in all the components. This can be a kind of tricky process to get right, so I recommend checking out some video tutorials like [this one](https://youtu.be/UwGoU3XVpnI) for proper safety and techniques for wiring outlets.

**Safety is the number one priority when dealing with electricity, especially AC line voltage, which has the power to *KILL YOU* if you aren't careful. Please take this seriously and make sure everything is unplugged before working on any wiring.**

#### Harvest wire from power cord (optional)
If you decide to harvest the wiring for inside the gang box from the power cable you're using, cut off a length of about 1-1 1/2 ft. of wire from the end of the cable and remove all of the outer insulation so you're left with three individual strands of wire. If you're using separate wire for inside the gang box, skip this step.

#### AC wiring to relays
[![Internal outlet wiring diagram](/assets/img/humidifier/light-wiring-diagram.png){: width="800"}](/assets/img/humidifier/light-wiring-diagram.png)

#### Relay control wires

## Finish assembly
Third major component

#### Hot glue relays in place
#### Secure outlets in place
#### Attach outlet cover
