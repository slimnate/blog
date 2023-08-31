---
title: Snake Tank Pt. 4 - Embedded Software
date: 2021-04-14 12:04:00 -0500
categories: [Projects]
tags: [arduino, programming, cpp]
math: true
mermaid: true # enable mermaid charts
pin: false
image: # article header image
  src: /assets/img/humidifier/header-software.png
---

This article covers the design and implementation of the arduino software for my [Snake Tank Humidifier]({% post_url 2021-04-14-snake-tank-humidity-controller %}) project.

1. TOC
{:toc}

# What + Why?
The next major component of the [Snake Tank Humidifier]({% post_url 2021-04-14-snake-tank-humidity-controller %}) project is the software, which is responsible for controlling all of the electronics sub-systems and providing remote control of the system with network connectivity

## Goals/Requirements
When designing the software for this project I wanted to ensure that the system could be monitored and updated remotely over the network, eliminating the need to change settings with code updates, and allowing for remote monitoring of the system status without a serial connection to a computer. In order to implement this functionality, there will be two separate code bases; one that runs on the arduino, and one for the mobile monitoring and control app. This article is focused on the code that runs on the arduino, the mobile app is discussed in the [next article]({% post_url 2021-04-14-snake-tank-mobile-app %}).

The arduino app consists of a few main components that control the electronics and provide network connectivity:
- Humidity controller
- Light controller
- Wifi Controller for connecting to a local WiFi network
- Remote time server connectivity
- Expose HTTP web server for the mobile app to communicate with

# How?

## Development Tools
The software is developed in C++ using the custom arduino compiler and [libraries](https://www.arduino.cc/reference/en/) for interfacing with the board. For compilation and uploading to device, I use the [Arduino IDE](https://www.arduino.cc/en/software). The board used for this project ([Arduino NANO 33 IoT](https://store.arduino.cc/usa/nano-33-iot)) is a SAMD based board and requires the [SAMD core to be installed](https://www.arduino.cc/en/Guide/NANO33IoT#use-your-arduino-nano-33-iot-on-the-arduino-desktop-ide) in the Arduino IDE. For actually writing the code I use my editor of choice - [VSCode](https://code.visualstudio.com/) - with some specific extensions for C++ and arduino development:

[Arduino](https://marketplace.visualstudio.com/items?itemName=vsciot-vscode.vscode-arduino)
: The Arduino extension makes it easy to develop, build, deploy and debug your Arduino sketches in Visual Studio Code

[C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
: The C/C++ extension adds language support for C/C++ to Visual Studio Code, including features such as IntelliSense and debugging

[Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
: A basic spell checker that works well with camelCase code

## External Dependencies
The software is designed to be pretty self-contained, but does still utilize a few external libraries to provide functionality that would be difficult to implement from scratch:

TODO: Dependencies info and links

# Component Controllers
Each component controller is designed to encapsulate the functionality of an external piece of hardware connected to the main board via one or more control pins. They each expose different methods for interfacing, depending upon the device. DHT22, AtomizerController, and FanController are all traditional objects which can be instantiated multiple times. Alternatively, the HumidityController and LightController are static classes which cannot be instantiated, and function more like a namespace than a class - the reasons why are discussed in the implementation notes of each of those classes

## DHT22
Responsible for interfacing with a DHT22 controller on a specific control pin and reading/exposing it's temperature and humidity values.

CPP Header
{: .code-label }

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/DHT22.h %}

Implementation
{: .code-label }

This class is designed to cache the `temperature` and `humidity` values whenever the `void updateValues()` method is called, and make the most recent value available via getter methods: `float getTemperature()` and `float getHumidity()`.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/DHT22.cpp %}

## AtomizerController
Responsible for enabling/disabling the atomizer and tracking it's current status via it's control pin.

CPP Header
{: .code-label }

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/AtomizerController.h %}

Implementation
{: .code-label }

This is a very simple class, with a constructor that takes a `controlPin` parameter, an `isEnabled()` that returns the value of an internal boolean flag, and has `enable()` and `disable()` methods that set the `controlPin` to a digital `HIGH` or `LOW` to control an external transistor on the circuit board.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/AtomizerController.cpp %}

## FanController
Responsible for enabling/disabling the fans and tracking their current status via it's control pin.

CPP Header
{: .code-label }

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/FanController.h %}

Implementation
{: .code-label }

This is another very simple class, implemented exactly the same way as the atomizer controller - with a constructor that takes a `controlPin` parameter, an `isEnabled()` that returns the value of an internal boolean flag, and has `enable()` and `disable()` methods that set the `controlPin` to a digital `HIGH` or `LOW` to control an external transistor on the circuit board.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/FanController.cpp %}

## HumidityController
Static class responsible for enabling/disabling the humidifier system, tying together the previous 3 classes internally to control each component. These files also contain the `HumidityControllerSettings` class, used to manage the current configuration of the humidity controller. The `HumidityController` class must be static in order for the [`TimeAlarms`](https://www.pjrc.com/teensy/td_libs_TimeAlarms.html) library to call the `update()` method on each update interval.

CPP Header
{: .code-label }

`HumidityControllerSettings` is a simple struct with 4 properties: `targetHumidity` (run humidifier until this humidity is reached), `kickOnHumidity` (turn humidifier on after falling below this humidity), `fanStopDelay` (time in seconds to run fans after atomizer is stopped - to clear remaining fog from reservoir), and `updateInterval` (time in seconds to check humidity levels and update system status).

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/HumidityController.h %}


Implementation
{: .code-label }

`HumidityController::init()`
: Initialization of the humidity controller needs to be done using the static `init()` method, which takes 4 control pin arguments for the individual sub-controllers, and a pointer to a `HumidityControllerSettings` object - using a pointer allows the object to be managed outside of the `HumidityController` class. After initializing the sub-component modules, the [TimeAlarms](https://www.pjrc.com/teensy/td_libs_TimeAlarms.html) library is used to create a repeating timer that calls the `update()` method with an interval of `settings->updateInterval` seconds. 

`HumidityController::update()`
: This method is called once per loop every `settings->updateInterval` seconds, and performs an update of both `DHT22` sensors, calculates the average humidity, and enables/disables the atomizer and fans according to the calculated average humidity and the thresholds in `settings->target` and `settings->kickOn`. When shutting down the system, the atomizer is turned off first, and then a `Alarm.timerOnce()` is used to stop the fans after a specified `fanStopDelay`.

`HumidityController::runHumidifier()`
: This method enables both the atomizer and fan controllers.

`HumidityController::stopAtomizer()` and `HumidityController::stopFans()`
: These methods disables the atomizer and fan controllers respectively.

`HumidityController::average()`
: Calculates and average of the two values `a` and `b`. Note that if `a` or `b` are equal to `0`, then they will be discarded from the calculation. This provides a fail-safe option in the event of one of the sensors not functioning properly.

`HumidityController::controlStatus()`
: Updates two boolean ref params - `aEnabled` and `fEnabled` - with the status of the atomizer and fan controllers respectively

`HumidityController::temperature()` and `HumidityController::humidity()`
: Each method updates three floating point ref params - `avg`, `one`, and `two` - with the average and individual sensor values for temperature and humidity respectively

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/HumidityController.cpp %}


## LightController
Responsible for turning the day/night lights off/on via the relays attached to day/night control pins.

CPP Header
{: .code-label }

Similar to the `HumidityControllerSettings` class, `LightControllerSettings` is a simple struct with 2 properties: `schedule` (a concrete instance of the abstract `Schedule` class that returns a `ScheduleEntry` for the current date/time - see [Utilities](#utilities) > [Scheduling](#scheduling)) and `updateInterval` (time in seconds to check humidity levels and update system status).

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/LightController.h %}

Implementation
{: .code-label }

`LightController::init()`
: Initialization of the light controller needs to be done using the static `init()` method, which takes 2 control pin arguments for the individual day/night relays, and a pointer to a `LightControllerSettings` object - using a pointer allows the object to be managed outside of the `LightController` class. After initializing the sub-component modules, the [TimeAlarms](https://www.pjrc.com/teensy/td_libs_TimeAlarms.html) library is used to create a repeating timer that calls the `update()` method with an interval of `settings->updateInterval` seconds. 

`LightController::update()`
: This method is called once per loop every `settings->updateInterval` seconds. It first gets the current `Date` and `Time` (classes from [Utilities](#utilities) > [DateTime](#datetime)), and then requests a `ScheduleEntry` from the `settings->schedule` for the current date (see see [Utilities](#utilities) > [Scheduling](#scheduling)). It then uses this `ScheduleEntry` to determine the correct day/night status for the current time, and enables/disables voltage on the relevant control pins to actuate the connected relays.

`LightController::getStatus()` and `LightController::getStatusString()`
: Both methods return the current day/night status of the controller - one as a `DayNight` object (an enum from [Utilities](#utilities) > [Scheduling](#scheduling)), and the other as a lowercase string representation.

`LightController::enableLights()`
: Given a `DayNight` object (see [Utilities](#utilities) > [Scheduling](#scheduling)), this method enables/disables the appropriate control pins and updates the `LightController::status` variable with the new value.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/LightController.cpp %}

# Networking
The networking classes are responsible for providing network related functionality to the rest of the software.

## NTPClient
Class that implements a basic [NTP](https://labs.apnic.net/?p=462) Client that sends requests over UDP and parses the incoming responses.

> Note: Current implementation does not take into account daylight savings time, so the time is an hour off during half of the year and correct the other half. Future updates will add functionality to get DST info from the NTP server and update the time according to our current time zone.

### NTP Protocol
The [NTP protocol](https://labs.apnic.net/?p=462) is fairly simple, and outlined in the image below. Each red box on the diagram represents one byte (8 bits) of the packet data. The numbers next to each row indicate the start and end indices for that row in the `packetBuffer` variable. This diagram applies to both the request and response packets, as in the NTP protocol the packet format is the same for both. The relevant portions of the packet are outlined below:

- **LI - Leap Indicator** - 2 bits indicating the leap year/second status - currently using `3` for unsynchronized
- **VN - Version number** - 3 bits indicating the protocol version - currently using version `4`
- **Mode** - 3 bits indicating the mode - using `3` for client mode
- **Stratum** - 8 bits indicating the type of clock we would like our time to be from - currently using `0` for unspecified, since we don't have a need for high precision
- **Poll** - 8 bits indicating the maximum time between successive NTP messages - not really relevant here, but defined to `6`
- **Precision** - 8 bits indicating the system clock precision, in $\log_{2}(x)$ seconds. To calculate this value requires several steps:

1. First, we need to find the frequency of the clock - in this case `48 MHz` or `48,000,000 Hz`.
2. Then we use the formula to take the inverse of that frequency and get the period (time between clock ticks): $\frac{1}{f} = p$ - where $f$ is the clock frequency in $Hz$ and $p$ is the clock period in ticks/second. Evaluate the expression to get the following: $1/48,000,000 = 2.083e^{-8}$ seconds.
3. The NTP server expects an integer value $x$ where $2^{x}$ evaluates to approximately the clock precision, so next we need to take the base-2 logarithm of this period with the following formula: $\log_{2}(p) = x$. Evaluate that expression to get $\log_{2}(2.083e^{-8}) = -25.51$, so the nearest integer value (rounded down) is $p = -25$.
4. Since $-25$ is a _signed_ integer - it has a _negative sign_ - it should be represented in it's [two's compliment](https://en.wikipedia.org/wiki/Two%27s_complement) binary representation. However, the `byte` elements that make up our buffer array are all _unsigned_ 8-bit values, we _could_ simply write `-25` in our code and let the compiler automatically perform the two's complement operation for us, but for the sake of clarity and not relying on the compiler, we'll manually perform the operation and hard code the resulting value:
  - To convert to two's compliment, we fist need to get the binary representation of 25: $$25_{10} = 00011001_{2}$$
  - We then perform a binary complement operation, which swaps every `1` and `0` in the number: $$00011001_{2} \rightarrow 11100110_{2}$$
  - To complete the two's-complement, we just need to add one to the complement: $$11100110_{2} + 1_{2} = 11100111_{2}$$
  - Then we just convert this value to hex: $$11100111_{2} = 231_{10} = E7_{16}$$

- **Root Delay** - 32 bits not used by client 
- **Root Dispersion** - 32 bits not used by client 
- **Reference Identifier** - 4 bytes ASCII code, indicating the reference clock type. For Stratum 0, this is irrelevant
- **Reference Timestamp** - 64 bits indicating time request was sent by client. 32 bits of integer part, and 32 bits of decimal part. _Not used_
- **Originate Timestamp** - 64 bits indicating time request was received by server. 32 bits of integer part, and 32 bits of decimal part. _Not used_
- **Receive Timestamp** - 64 bits indicating time request was sent by server. 32 bits of integer part, and 32 bits of decimal part. _Not used_
- **Transmit Timestamp** - 64 bits indicating time request was received by client. 32 bits of integer part, and 32 bits of decimal part. _This is the value we will use for our time determination_

![NTP Packet Diagram](/assets/img/humidifier/ntp-packet-diagram-annotated.png)

CPP Header
{: .code-label }

This file contains the definition for the `NTPClient` class, as well as definitions of constants that are used internally:

- `NTP_DEFAULT_PORT = 8888;` - default local port that the underlying UDP instance will use
- `NTP_DEFAULT_SERVER = "us.pool.ntp.org";` - default ntp server name
- `NTP_DEFAULT_TIMEZONE = -6;` - default time zone
- `NTP_PACKET_BUFFER_SIZE = 48;` - size of the internal request/response buffer in bytes
- `NTP_REQUEST_PORT = 123;` - the remote port that NTP requests will be sent to.
- `NTP_RESPONSE_WAIT_TIME = 1500;` - the maximum time in ms to wait for an NTP response
- `NTP_UNIX_TIME_OFFSET = 2208988800UL;` - constant representing the number of seconds between 1/1/1900 and 1/1/1970. Used to convert from UTC to Unix time.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/NTPClient.h %}

Implementation
{: .code-label }

`NTPClient::NTPClient(...)` - constructor
: There are 4 overloaded constructors, that allow for creation of an object with default values. The only required value is a `WiFiUDP` instance (from the [WiFiNINA](https://www.arduino.cc/en/Reference/WiFiNINA) module) that is used for sending/receiving web requests.`settings->updateInterval` seconds. The other three valid signatures are:

- `NTPClient(WiFiUDP udp, int timeZone)`
- `NTPClient(WiFiUDP udp, String server, int timeZone)`
- `NTPClient(WiFiUDP udp, String server, u_int port, int timeZone)`

`NTPClient::initUDP()`
: This method must be called _after_ connecting the device to a WiFi network, and _before_ sending/receiving any requests, and takes care of initializing the underlying `WiFiUDP` instance

`NTPClient::getNTPTime()`
: This method returns the current time from a remote NTP server. First, it clears any incoming UDP requests to make sure we parse the right response. Next it takes care of making a DNS request to resolve an IP address from the ntp server url. Since the current implementation utilizes a public NTP server pool, this IP address is usually different, and depends on your region, etc. Once the IP address is resolved, we call the `sendNTPRequestPacket()` which builds and sends the NTP request to the remote server. Then we call, and return the result of, the `receiveNTPResponsePacket()` method which receives the response and returns a `time_t` type variable with the time received from the server.

`NTPClient::sendNTPRequestPacket()`
: This method creates and sends an NTP request packet to the specified `IPAddress`. The contents of the request are created inside a `packetBuffer` - a byte array of size 48, with the structure shown in the diagram below. We build a packet according to this diagram, open a UDP connection to the remote server, write the bytes of the packet to the connection stream, close the stream, and return.

`NTPClient::receiveNTPResponsePacket()`
: This method receives and parses a NTP response packet from the remote server. It waits a specified time (default 1500 ms) for a response to come in, returning `0` if a response is not received in time. If a response is received, the size is confirmed, and the response data is buffered into `packetBuffer`. This buffer can be shared between the send and receive methods since the request and response packet share the same format (see below). We parse the first 32 bits of the _Transmit Timestamp_ section of the response packet into an unsigned long variable, convert it from UTC to Unix-style time, update the time based on the specified time-zone, and then return the value to the caller.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/NTPClient.cpp %}

## WebServer
The WebServer module is probably one of the more complex modules in this application. It's a bare bones implementation of the HTTP protocol that wraps the `WiFiServer` class from the [WiFiNINA](https://www.arduino.cc/en/Reference/WiFiNINA) module. It handles detecting and parsing incoming web requests (parses HTTP method, query params, headers, and body content), and provides the `WebRequest` and `WebResponse` classes which allow us to process incoming requests as well as build and send responses.

CPP Header
{: .code-label }

This file contains the definitions for many internal constants:
1. Server constants, such as default port, line buffer size, and line terminator character.
2. Line mode status (request, header, body) for determining how to parse a specific line.
3. Parser status (success, fail).
4. Data size constants - determine the size of internal arrays and string buffers used during sending, receiving, and parsing.
5. HTTP Status codes - string representations of common http status codes that I may use when sending a response. It also defines the following classes, discussed in more detail in the implementation notes below:
  - `WebServer`
  - `WebRequest`
  - `WebResponse`
  - `QueryParam`
  - `HttpHeader`

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/WebServer.h %}

Implementation
{: .code-label }

**WebServer**

The web server class is responsible for handling and parsing incoming HTTP requests

`WebServer::WebServer()` - constructor
: The web server constructor takes an optional `byte` parameter specifying the port to listen on.

`WebServer::listen()`
: This method starts the underlying `WiFiServer` instance listening for incoming requests.

`WebServer::processIncomingRequest(WebRequest& req)`
: This method is called once per application update loop (see [Main Arduino File](#main-arduino-file---climate_controlino) for details on main loop), and checks for an incoming request. If there is an incoming request available, the contents of the request are parsed line by line by the specialized parsing functions, and the reference parameter `req` is updated with the contents of the request. If the request parsing is successful the method returns `1` to inform the caller of the success, if the parsing fails the method returns `-1` to inform the caller of failure.

`WebServer::readLine(WiFiClient client)`
: This is a helper method that reads the next available line from `client` into the internal `_lineBuffer` variable, using the `WS_LINE_TERMINATOR` to determine the end of the line.

`WebServer::parseLineRequest(char* method, char* path, char* params, char* version)`
: This method is parses the first line of the request, which contains the method, path, and HTTP version. The supplied char buffers are updated with the text from the parsing results - `method` gets the HTTP method, `path` the request path excluding any query parameters found, `params` the full string of query params, and `version` the HTTP version text.

`WebServer::parseQueryParams(char* paramStr, QueryParam* dest)`
: This method is responsible for further parsing the raw query param string into an array of `QueryParam` objects that can be stored in the final `WebRequest` object. We loop through the characters of `paramStr`, using a `keyBuffer` and `valueBuffer` to store each char depending on whether the current char is part of a key or part of a value. We look for special characters `?`, `&`, and `=` to determine this. The resulting params are added to the `QueryParam[]` pointed to by `dest`.

`WebServer::parseLineHeader(char* key, char* value)`
: This method is responsible for parsing the contents of `_lineBuffer` as a header line, and setting `key` to the header name and `value` to the header value.

**WebRequest**

The `WebRequest` is responsible for wrapping all the properties of web request in a single object, and providing a method to get a `WebResponse` object that can be used to respond.

`WebRequest::getResponse()`
: This method builds ad returns a `WebResponse` object that corresponds to this `WebRequest`. It copies over the `client` and `httpVersion` properties, and adds a default status of `200 OK` as well as the following default headers: `Content-Type text/plain`, `Server: Arduino NANO 33 IoT - Snake Tank Controller`, and `Connection: close`.

`WebRequest::getHeader(String name, HttpHeader& dest)`
: This method is used to access a specific header from this request. The `HttpHeader` object header with the specified `name` will be assigned to the `HttpHeader` object referenced by the `dest` parameter.

**WebResponse**

The `WebResponse` is responsible for providing an interface to build a response to a specific web request, and providing a method to send that request to the remote server.

`WebRequest::addHeader()`
: The addHeader method is used to add an HTTP header to the response, and returns `1` on success, and `-1` on failure (in the case that this `WebResponse` already has the maximum supported number of headers). There are four overloads of this method: one that accepts an `HttpHeader` object directly, and three that accept two parameters: `key` and `value`. The two-parameter overloads all accept a C-string for the `key`, and one of the following types for `value`:
- `char*` - C-string value of header
- `float` - float value of header that will be converted to C-string
- `long` - long value of header that will be converted to C-string

`WebRequest::send()`
: This method is responsible for sending the built response to the requesting client. It checks the client is still connected, calculates the size of `body` and generates a `content-length` header, and then serializes and sends the bytes of the response to the client. We then close the connection and return `1` for success. If part of the process fails, `-1` is returned to inform the caller.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/WebServer.cpp %}

## Router
Provides a simple REST-ful(ish) HTTP router implementation. I have a decent amount of experience with the [express.js](https://expressjs.com/) library for NodeJS, so I took the inspiration for this routing library from that. This bare bones module provides the ability to define routes with any HTTP method and static path (_static_ meaning it does not support parameterized routes, like `/items/:id/` - _yet_), and callback function. It can then automatically route incoming requests to the appropriate callback function based on the method and path of the request.

CPP Header
{: .code-label }

This file contains the definitions for the `Route` and `Router` classes, the max number of routes supported by the router, and a custom type definition for route callback functions:

- `rest_callback_t` - defines a custom type representing a pointer to a function that accepts two parameters of type `WebRequest` and `WebResponse` in that order
- `ROUTER_MAX_ROUTES = 20;` - defines the maximum number of routes that a router instance can hold.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/Router.h %}

Implementation
{: .code-label }

`Router::route(String method, String path, rest_callback_t cb)`
: This method is the main method that allows for defining new routes, given the HTTP `method`, the request `path`, and a pointer to the desired `cb` function.

`Router::get(String path, rest_callback_t cb)`
: A shortcut for registering a new route that uses the HTTP `GET` method.

`Router::post(String path, rest_callback_t cb)`
: A shortcut for registering a new route that uses the HTTP `POST` method.

`Router::handle(String path, rest_callback_t cb)`
: This method is responsible for routing incoming requests to th correct handler/callback function. It looks through each registered route and finds one that matches the `method` and `path`. If a matching route is found, a `WebResponse` object is created using the `WebRequest::getResponse()` function, and the callback function is called with the existing request and new response parameter. If no matching route is found, the router automatically responds to the client with a `404 Not Found` response.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/Router.cpp %}


## WifiController
This class encapsulates the functionality of the WiFiNINA module, such as verifying and establishing wireless connections, in an easy to use static class.

CPP Header
{: .code-label }

This file contains the definitions for the `WifiController` and `WifiControllerSettings` classes:

- **WifiControllerSettings** - Struct representing wifi connection settings such as SSID and password
- **WifiController** - Static class providing methods for connecting to networks and monitoring/displaying network status

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/WifiController.h %}

Implementation
{: .code-label }

global `encryptionTypeToString(byte encryptionType)`
: Global method that converts an encryption type code to the corresponding string. Returns `"Unknown"` for invalid encryption type.

`WifiController::init(WifiControllerSettings* s)`
: This method is responsible for verifying the status of the wifi module and firmware, loading in the device mac address, connecting to the network specified in `settings`, displaying the connection status, and setting up a repeating timer to continually check for and resolve any connection issues.

`WifiController::statusToString(byte status)`
: Helper method that converts a connection status code to a string. Returns `"N/A"` for invalid status.

`WifiController::verifyModule()`
: Verify that the WiFiNINA module is properly installed on the device. Return false if installation issues found, true otherwise.

`WifiController::verifyFirmware()`
: Verify that the WiFiNINA firmware is properly installed on the device. Return false if installation issues found, true otherwise.

`WifiController::WifiController::getMacAddress()`
: Return a `MacAddress` object (see [Networking](#networking) > [WifiData](#wifidata)) representing the MAC address of the current device.

`WifiController::WifiController::connect()`
: Connect to the WifiNetwork specified in `settings->ssid` and `settings->password`. Automatically retry connection up to three times upon connection failure, allowing 5 seconds between each attempt.

`WifiController::WifiController::checkConnectionStatus()`
: Called once per `settings->connectionCheckInterval` ms, and responsible for checking the connection status, and reconnecting if status is not `WL_CONNECTED`.

`WifiController::WifiController::printAvailableNetworks()`
: Scan available networks to get count, and use the `printNetwork()` function to display details for each.

`WifiController::WifiController::printNetwork(byte i)`
: Print the network details (ssid, mac, encryption type, channel, and signal strength) of the available wifi network identified by `i`.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/WifiController.cpp %}

## MacAddress
Struct representing a mac address, stored as a `byte` array of size 6.

CPP Header
{: .code-label }

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/MacAddress.h %}

Implementation
{: .code-label }

`MacAddress::MacAddress(byte b[6])` - constructor
: Create a new `MacAddress` object, storing the provided value of `b` in the local `bytes` variable

`MacAddress::toString()`
: Convert the address stored in `bytes` to a string, represented in hexadecimal format.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/MacAddress.cpp %}

## routes
This field contains definitions of all the route handler callback functions used when defining routes (see [Networking](#networking) > [Router](#router)). It also contains some global helper methods used inside the route handlers, and constants defining all the different header names used in the handlers.

CPP Header and Implementation
{: .code-label }

`bool updateFixedSchedule(String body)` - helper method
: Parse a request `body` to get a `FixedSchedule` (see [Utilities](#utilities) > [Scheduling](#scheduling)) and update the global `lightControllerSchedule` (see [climate_control.ino](#main-arduino-file---climate_controlino)) with the new schedule.

`bool updateMonthlySchedule(String body)` - helper method
: Parse a request `body` to get a `MonthlySchedule` (see [Utilities](#utilities) > [Scheduling](#scheduling)) and update the global `lightControllerSchedule` (see [climate_control.ino](#main-arduino-file---climate_controlino)) with the new schedule.

`route_getTest`
: Handles the `GET /test` route, used for testing the web server functionality. This handler prints the first 4 query params from `req.params`, adds a new header called `Header-Test` to the response, adds a test body contents, and sends response.

`route_getTime`
: Handles the `GET /time` route, used by the mobile app to display the servers current time. This handler returns the time as response headers in two formats: as a raw UTC value, and as local time in individual component value (year, month, day, hours, minutes, seconds)

`route_getHumiditySettings`
: Handles the `GET /humidity/settings` route, used by the mobile app to display the current humidity controller settings. This handler returns 4 values as headers: target, kick-on, fan stop delay, and update interval

`route_postHumiditySettings`
: Handles the `POST /humidity/settings` route, used by the mobile app to update the current humidity controller settings. This handler parses optional parameters from the request headers (target, kick-on, fan stop delay, and update interval), updating a `Bitflag` depending which parameters were provided on the request. Then we use the bitflag to determine which values to update, adding a response header with the new value afterwards. Finally once all settings are updated, the response is sent.

`route_getHumidityStatus`
: Handles the `GET /humidity/status` route, used by the mobile app to display the current status of the humidity controller. This handler returns the following values as response headers: average and individual temperature, average and individual humidity, and enabled/disabled status of the atomizer and fans.

`route_getLightStatus`
: Handles the `POST /lights/status` route, used by the mobile app to display the current day/night light status. This handler returns a single header with a string representing the current light status - either `day` or `night`.

`route_getLightSchedule`
: Handles the `GET /lights/schedule` route, used by the mobile app to display the current light schedule. This handler returns a header with the schedule type (`1` for fixed, `2` for monthly), and body text containing one `ScheduleEntry` per line in the format: `D{HH:MM:SS} N{HH:MM:SS}` - one entry for fixed, 12 for monthly

`route_postLightSchedule`
: Handles the `POST /lights/schedule` route, used by the mobile app to update the current light schedule. This handler accepts a header with the schedule type (`1` for fixed, `2` for monthly), and body text containing one `ScheduleEntry` per line in the format: `D{HH:MM:SS} N{HH:MM:SS}`- one entry for fixed, 12 for monthly. It uses the `updateFixedSchedule()` or `updateMonthlySchedule()` to update the schedule, and returns a response equivelant to that of the `GET /lights/schedule` route with the newly updated schedule.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/routes.h %}


# Utilities

## Bitflag
Class that implements a basic [Bit Flag/Bit Field](https://en.wikipedia.org/wiki/Bit_field) algorithm. Bit flags are a memory compact way of storing multiple boolean values (flags) as the individual bits in a single variable. You use the bitwise OR operator `|` to set bits, and the bitwise AND operator `&` to check if individual bits are set.

CPP Header
{: .code-label }

This file contains the definitions for the `Bitflag` class. The bits are stored on a private variable `_bits`, and methods are provided to interact with the bits. Since this class is only currently used for one purpose - determining which values are requesting to be updated from the `POST humidity/settings` route (see [Networking](#networking) > [routes](#routes)) - it also defines unique bit constants, each corresponding to a specific field. If the flag for a field is set, the request handler knows to update that field with the provided value.

- `BIT_HUM_TARGET   = 0b1000;` - humidity target field
- `BIT_HUM_KICK_ON  = 0b0100;` - humidity kick on field
- `BIT_HUM_FAN_STOP = 0b0010;` - humidity fan stop field
- `BIT_HUM_UPDATE   = 0b0001;` - humidity update field

>Note: The current flag only need up to 4 bits, so we could use a byte or smaller variable type, but to allow for extensibility, the `_bit` field and all method arguments accept `u_int` allowing this class to work with up to 32 bits.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/Bitflag.h %}

Implementation
{: .code-label }

`Bitflag::setBit(const u_int toSet)`
: This method sets the bit(s) specified by `toSet` to `1` in the local `_bits` variable.

`Bitflag::checkBit(const u_int toCheck)`
: This method checks if an individual bit specified by `toCheck` is `1` in the local `_bits` variable. If bit is set returns true, otherwise returns false.

`Bitflag::checkAny()`
: This is a helper method to easily determine if any bits have been set yet. Returns true if the value of `_bits` is non-zero, false otherwise.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/Bitflag.cpp %}

## DateTime
This module provides a `Date` and `Time` class, as well as a `Comparable<T>` interface that they both implement.

CPP Header
{: .code-label }

This file contains the definitions for the three classes (`Comparable<T>`, `Date`, and `Time`):

- **Comparable<T>** - interface that defines a single virtual method, `virtual int compare(T);`, which allows for comparing two objects, for example `a.compare(b)` will return 1 if `a > b`, 0 if `a = b`, and -1 if `a < b`
- **Date** - represents a date with `year`, `month`, and `day` properties
- **Time** - represents a time with `hours` `minute`, and `second` properties

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/DateTime.h %}

Implementation
{: .code-label }

`compareWholeNumber(byte first, byte second)` - helper method
: compares `first` and `second`, returning 1 if `first > second`, 0 if `first = second`, and -1 if `first < second`

`compareWholeNumber(int first, int second)` - helper method
: compares `first` and `second`, returning 1 if `first > second`, 0 if `first = second`, and -1 if `first < second`

`Date::Date(...)` - constructor
: The Date class has two constructors, allowing you to pass either `year, month, day`, or `day, month, year`

`Date::compare(Date other)`
: Compare `this` to `other` returning `1`, `0`, or `-1` depending which date is earlier. Each date component is compared individually in order of it's magnitude - first `year` is compared, then `month`, then `day`.

`Date::compareDay(Date other)`
: Compare `this.day` to `other.day` returning `1`, `0`, or `-1` depending which date is earlier.

`Date::compareMonth(Date other)`
: Compare `this.month` to `other.month` returning `1`, `0`, or `-1` depending which date is earlier.

`Date::compareYear(Date other)`
: Compare `this.year` to `other.year` returning `1`, `0`, or `-1` depending which date is earlier.

`Date::printSerial()`
: Print this date object to serial interface using `Serial.write()`

`Time::Time(byte hours, byte minutes, byte seconds)` - constructor
: The Time class only has one constructor that takes `hours`, `minutes`, and `seconds` in that order.

`Time::compare(Time other)`
: Compare `this` to `other` returning `1`, `0`, or `-1` depending which time is earlier. Each time component is compared individually in order of it's magnitude - first `hour` is compared, then `minute`, then `second`.

`Time::compareHours(Time other)`
: Compare `this.hours` to `other.hours` returning `1`, `0`, or `-1` depending which is earlier.

`Time::compareMinutes(Time other)`
: Compare `this.minutes` to `other.minutes` returning `1`, `0`, or `-1` depending which is earlier.

`Time::compareSeconds(Time other)`
: Compare `this.seconds` to `other.seconds` returning `1`, `0`, or `-1` depending which is earlier.

`Time::toString(char *dest)`
: Set the value of `dest` to the string representation of this time object in the format `HH:MM:SS`, adding padding zeros where necessary.

`Time::printSerial()`
: Print this date object to serial interface using `Serial.write()`

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/DateTime.cpp %}

## lines
this module provides a class `Lines` that represents a collection of strings (lines). This is used when parsing the body of HTTP requests for included light schedule data. This simplifies the process of having multidimensional string arrays, which is much more of a pain in C++ than other languages I'm used to.

CPP Header and Implementation
{: .code-label }

`LINE_COUNT`
: This represents the max number of lines that can be stored ina  single `Lines` instance.

`LINE_SIZE`
: This represents the max number of characters that can be stored in a single line (this includes the terminating NULL, so the effective size is really `LINE_SIZE - 1`).

`Lines::count()`
: Returns the number of lines currently stored in this object.

`Lines::addLine(const char* line)`
: Store a string as a new line of text into this object.

`LLines::getLine(char* dest, int index)`
: Copy the string stored in line `index` to the `dest` string.

`Lines::split(const char* inStr)`
: Split the string in `inStr` into individual lines, using `\n` as the line delimiter, and return a new `Lines` object containing them.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/lines.h %}

## Scheduling
This module provides a number of classes that work together to provide extensible light scheduling functionality for the application.

CPP Header
{: .code-label }

This file defines two enums, `ScheduleType` and `LightStatus`, and several classes:

- **ScheduleEntry** - this class defines a day and night start time for a specific date/time range, and logic to determine the status for a specific time.
- **Schedule** - this is an abstract class that each schedule implementation inherits from
- **FixedSchedule** - concrete `Schedule` implementation that provides a single fixed entry no matter the date.
- **FixedSchedule** - concrete `Schedule` implementation that provides a different entry for each month, 12 in total.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/Scheduling.h %}

Implementation
{: .code-label }

`ScheduleEntry::ScheduleEntry(Time dayStart, Time nightStart)` - constructor
: Create a new schedule entry with the specified `dayStart` and `nightStart` times.

`LightStatus ScheduleEntry::getLightStatus(Time t)`
: Calculate and return the `LightStatus` for a specific time `t` using the `compare()` method to compare `t` with `dayStart` and `nightStart` - if `t < dayStart || t >= nightStart` returns `LightStatus.NIGHT`, if `t >= dayStart && t < nightStart` returns `LightStatus.DAY`. 

`void ScheduleEntry::toString(char* dest)`
: Set the value of `dest` to a string representation of the current schedule entry in the form `D{<dayStart>}N{<nightStart>}` where `<dayStart>` and `<nightStart>` are strings in the format `HH:MM:SS`. This is used as the schedule entry representation when sending or updating the light settings over the network.

`bool Schedule::validScheduleType(int i)`
: This is a helper method to ensure that `i` represents a valid `ScheduleType` - returns true if `i == ScheduleType.FIXED || i == ScheduleType.MONTHLY`

`FixedSchedule::FixedSchedule(ScheduleEntry* entry)` - constructor
: Create a fixed schedule with the specified `entry`

`ScheduleEntry* FixedSchedule::getEntry(Date d)` - override of `Schedule::getEntry(Date d)`
: Return the `ScheduleEntry` associated with the specified date `d`. Fixed schedule always returns the same value since it only has one entry.

`int FixedSchedule::getScheduleType()`
: Returns the `ScheduleType` value associated with this schedule implementation: `ScheduleType::FIXED`

`void FixedSchedule::toString(char* dest)`
: Set value of `dest` to the string representation of this schedule. Used to send/update schedules over the network. This implementation is represented by one line, the value of `this->entry.toString()`

`MonthlySchedule::MonthlySchedule(ScheduleEntry* sched[12])` - constructor
: Create a monthly schedule with the twelve specified entries `sched`, one for each month, assigned to the local variable `schedules`. `sched[0]` = Jan, `sched[1]` = Feb, and so on.

`ScheduleEntry* MonthlySchedule::getEntry(Date d)` - override of `Schedule::getEntry(Date d)`
: Return the `ScheduleEntry` associated with the specified date `d`. Monthly schedule returns the `entry` associated with the current month of `d`.

`int MonthlySchedule::getScheduleType()`
: Returns the `ScheduleType` value associated with this schedule implementation: `ScheduleType::MONTHLY`

`void MonthlySchedule::toString(char* dest)`
: Set value of `dest` to the string representation of this schedule. Used to send/update schedules over the network. This implementation is represented by twelve lines, one for each `ScheduleEntry` in `schedules`. Each line will have the value of `this->schedules[i].toString()` where `i` is the month, `0` through `11`

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/Scheduling.cpp %}

# Constants

## secrets
`secrets.h` defines the SSID and password for the wifi network the device should connect to. It should _NOT_ be checked in to source control with any passwords in it.

CPP Header
{: .code-label }

This file simply defines two constant char arrays:

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/secrets.h %}

## globals
`globals.h` contains the definitions for all global variables that need to be accessible throughout various parts of the program. This includes the settings for the controller classes, as well as network classes. This class is used to ensure that the globals can be included in any files where they are needed to accessed, and includes compiler directives to ensure that they are only defined a single time.

CPP Header
{: .code-label }

This file defines several variables for the controller classes. These are defined as globals so that they can be read by the controller classes and updated by the web server route handlers.

- `humidityControllerSettings` - current settings for the `HumidityController` class
- `lightControllerSettings` - current settings for the `LightController` class
- `wifiControllersettings` - current settings for the `WifiController` class
- `lightControllerSchedule` - current schedule for the `LightController` class

It also defines some networking variables. These are defined as globals to allow them to be accessed by both the main event loop and the `routes.h` and other networking related classes.

- `udp` - an instance of `WiFiUDP` used by `ntp`
- `ntp` - an instance of `NTPClient`, used to send and receive NTP time
- `server` - an instance of `WebServer` for processing incoming HTTP requests
- `router` - an instance of `Router` for routing incoming HTTP requests to the right handler

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/globals.h %}


# Main Arduino File - climate_control.ino
This file is the entry point for the program that ties together all the other code in the project and is responsible for starting up the application and performing actions during the main program loop.

CPP Header
{: .code-label }

Control pins
: First, we define some control pins that will be provided to the controller modules.

Defaults
: Next we define a bunch of settings defaults that will be used to initialize the settings of the various controller modules.

Global functions
: Then we declare some global functions that will be implemented later on, so they can be referenced in the `setup()` and `loop()` functions

`void setup()`
: The setup function is responsible for initializing all of the various controller modules and networking functionality. First, it waits for a serial connection, timing out after two seconds if no serial connection is available. Next we setup default settings and call the `init()` method for the each of the humidity, light, and wifi controllers. Then we initialize the global `NTPClient` and set the sync provider for the [Time](https://www.pjrc.com/teensy/td_libs_Time.html) library. Then, after printing the current date and time, we finally initialize the global `WebServer` and register the routes

`void loop()`
: The loop function checks for incoming web requests, and responds to them if there are any, and then calls the `Alarm.delay()` function of the [TimeAlarms](https://www.pjrc.com/teensy/td_libs_TimeAlarms.html) library which calls all of our controllers repeating timer functions, and waits for a certain time before exiting the loop function so it can run again. The delay is used to prevent the loop function from being called too often, increasing CPU load and heat.

`time_t timeProvider()`
: Wrapper function that can be passed to `setSyncProvider()` function of [Time](https://www.pjrc.com/teensy/td_libs_Time.html) library. Calls the ntp.getNTPTime() function and returns it's return value.

`void registerRoutes()`
: Registers all the routes defined in [routes.h](#routes) with the global `router` object.

{% git_include https://github.com/slimnate/arduino_climate_control/blob/master/climate_control.ino %}