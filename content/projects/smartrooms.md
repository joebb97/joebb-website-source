---
title: "Smart Rooms"
draft: false
author: Joey Buiteweg
---

## Demonstration

In this demo, I have the room's light set to be red. This is why the light changes when I enter the room.

My project partner Sharang has it set to be orange, and since he has higher priority than me, the light changes to orange.

After Sharang leaves, however, they change back to red.

{{< youtube bgIFu333o0k >}}

## Quick Bullets

In this project my teammates and I:

- Conceptualized a project to apply a user's settings for a specific rooms in their home automatically when the user's presence in a room is detected. User settings included the music playing in a room and the brightness and color of the room's lights.

- Wrote and debugged firmware for the ESP32 SoC to gather Bluetooth Low Energy RSSI measurements, detect the presence of users carrying an Eddystone beacon, and to communicate with user peripherals like smart lightbulbs and speakers.

- Architected a web application for users to edit their settings, establish user priority, register devices and rooms, and communicate with measurement devices to update room settings using Flask, Python, Heroku, Jinja templates, and Postgres.

- Coordinated with teammates to enable successful communication between measurement devices, room peripherals, and the web application.

- Collaborated with other teammates confirm the requirements for our PCB and keep the project on schedule.

- Enforced access restrictions between user accounts to ensure safety, security, and integrity of sensitive user data.

## Project Poster

![The poster](/473poster.jpg)

## Web UI Screenshot

![The UI](/473web-ui.png)

## System Architecture Flowchart

![The flowchart](/473flowchart.png)

## Database Schema

![the schema](/473db.png)

## Hardware Utilized

- Raspberry Pi 3 running as an ethernet bridge and music speaker.
- [LIFX Smart Lightbulb](https://www.lifx.com/pages/lightbulbs)
- [ESP32 Wireless Soc](https://www.espressif.com/en/products/socs/esp32/overview)
- [Radbeacon Eddystone Beacon](https://store.radiusnetworks.com/collections/hardware/products/radbeacon-01-dot)
- [TP-Link N300 Router](https://www.amazon.com/gp/product/B001FWYGJS/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)

## Reflections

This project could've been improved in a couple of ways:

- It was **incredibly** insecure and very much a **privacy hazard**. The webserver was never configured to use HTTPS, meaning an attacker could freely spy on a user's network to see which rooms they're in, modify their devices, etc. We literally sent unencrypted measurements of bluetooth RSSI from the ESP32 out through the internet to our webserver.

  - Despite this, if our novel prototype were a real product I'm sure someone would've bought or funded it though.

  - 🤔🤔🤔

- The peripheral control and measurement devices connected to a user's home network using WPS, which is [not secure](https://en.wikipedia.org/wiki/Wi-Fi_Protected_Setup#Vulnerabilities).

- No cryptography was used to verify that updates to a room's settings came from the Smart Rooms webserver. This means anyone who intercepted and sent the right HTTP replies to the right places could definitely change a user's settings without them asking, even with a home network's NAT firewall enabled.

  - The settings stored on the webserver weren't at risk here, but anyone could reply to the peripheral controlling devices that were polling for the room's settings with made up answers.

  - Measurements from the ESP32 could be spoofed by anybody, anywhere, since they weren't authenticated. The ESP32 was simply identified by User-Agent, which anybody can lie about. This also means other users could lie about their ESP32's provided ID to read (but not modify) the settings of other users.

- In addition to almost nonexistent network security, we didn't really exercise any defensive programming practices for our C firmware running FreeRTOS.
  - Our code had plenty of calls to `strcpy`, `sscanf`, `sprintf`, all of which are vulnerable to buffer overflow.

Overall, security wasn't considered for the project since it was simply a prototype and our biggest priority was just to get something working.

- On the server side, we handled a fair amount of timestamped RSSI measurements. These measurements are really time-series data, which are well suited to be stored in a time-series database like [InfluxDB](https://www.influxdata.com/). This is especially useful when deciding whether measurements indicate a user is in a room. This decision process could consider the average of the last N measurements from a device or use other algorithms. Regardless of the decision algorithm, a time-series database can greatly facilitiate querying timestamped data.

  - We used a relational database for our application, which was the right choice for the rest of our data since it had lots of structure. Homes have rooms, rooms have devices, so on and so on. But the RSSI measurements probably could've been shoved into InfluxDB. The tradeoff here is added complexity and maintenance though, since two databases is more than one.

  - Us being Computer Engineering and Electrical Engineering students, I think it's reasonable that none of us had ever heard of a time-series database when doing our project (the CS curriculum never talks about them either as far as I know). Knowing this family of databases exists will definitely be helpful in future IoT projects though.
