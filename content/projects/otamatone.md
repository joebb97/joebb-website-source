---
title: "Auto Otamatone"
draft: false
author: Joey Buiteweg
---

## The Finished Project

{{< myyoutube list="PL3mMMVIGL8i31Vo1rcE0b6XtApaTJtRdq" index="0" >}}

## Quick Bullets

In this project my teammates and I:

* Conceptualized a project for automated playing of the toy fretless instrument called the Otamatone.

* Developed a Stepper Motor and Servo driver on an FPGA using Verilog to move the playhead when keyboard keys were pressed.

* Interfaced C firmware with drivers using Memory Mapped I/O to rotate the motor and activate the servo.

* Collaborated closely with two teammates to establish requirements for the chassis and other hardware and to keep the project on schedule.

* Designed circuitry to analyze the electrical signal frequency of the Otamatone using Op-Amps, which helped enable self-tuning functionality.

* Created a novel P-controller to automatically tune the instrument using GPIO interrupt handlers written in C.

* Wrote additional interrupt handlers in C to process UART signals from a Raspberry PI connected to a USB MIDI keyboard.

## Under Construction Videos

{{< myyoutube list="PL3mMMVIGL8i31Vo1rcE0b6XtApaTJtRdq" index="1" >}}

## Project Poster

![The poster](/373poster.jpg)

## Hardware Utilized

* [Microsemi\'s SmartFusion SoC](https://www.microsemi.com/product-directory/soc-fpgas/1693-smartfusion)
* [SN754410 H-Bridge](https://www.ti.com/lit/ds/symlink/sn754410.pdf)
* Raspberry Pi 3
* A [voltage comparator](https://www.ti.com/lit/ds/symlink/lm2903b.pdf?ts=1606512923694&ref_url=https%253A%252F%252Fwww.ti.com%252Famplifier-circuit%252Fcomparators%252Fproducts.html) from Texas Instruments.
* [Hitech HS-422 Servo](https://servodatabase.com/servo/hitec/hs-422)
* [Nema 23 Hybrid Stepper Motor](https://www.pololu.com/product/1476)
* [Otamatone Deluxe](https://otamatone.com/352/otamatone-deluxe/)
* [Akai MPK Mini](https://www.akaipro.com/mpk-mini-mkii)

## Reflections

This project could've been improved in a couple of ways:

* A majority of our time for the project was spent getting the stepper motor working by flipping inputs to an H-bridge from an FPGA, which ended up being ~300 lines of Verilog. If you've written HDL before, you know that it takes forever to debug. We thought it would be crucial to implement this driver in hardware since we wanted the playhead to move as fast as possible. Whether this mattered or not I don't know, but we could've saved a bunch of time using a premade stepper motor driver such as the [A4988](http://www.geeetech.com/Documents/A4988-Datasheet.pdf) (a slew of other drivers can be found in this [blog post](https://medium.com/jungletronics/quick-intro-to-motor-drivers-322e4929db44)). 

* We should've used a [motor encoder](https://en.wikipedia.org/wiki/Rotary_encoder) to monitor how much the playhead **actually** moved along the track. We simply assumed that whenever we told the stepper to take 1 step, that it actually took that step, which doesn't always happen in reality. 

  * The motor would somtimes get snagged on the track and take less than a full step (especially when making small adjustments for self-tuning), which would then cause the state of our software to drift out of sync with where the playhead actually was.

  * This was especially problematic because the self-tuning mechanism updated the internal step count of our firmware. Because of this, we had to restart the whole system a few times on demo-day, which was quite unfortunate. This behavior can be seen in the fourth video from the playlist linked above.

* In addition to a motor encoder, a full on [PID controller](https://en.wikipedia.org/wiki/PID_controller) would've yielded much better results when self-tuning. Our only insight into the performance of the system was the frequency that the Otamatone was playing compared with the correct frequency of the key pressed on the MIDI keyboard. This difference in frequency is the perfect input for a PID controller, with the position of the playhead being the output. Unfortunately, we just didn't have the time to implement one in software like we did with the P-controller. Adding the actual state of motor to our feedback loop using an encoder also would've helped immensely.

* I don't remember whether we used the Nema 23 in unipolar or bipolar mode, but bipolar stepper motors provide more torque than their unipolar counterpart, which could've let us eke out some more RPMs from the motor. The downside to bipolar mode is that is harder to operate, which isn't ideal for a project with a short timeline like ours.


(Apologies for the console errors on this page and other pages with embedded youtube videos, it seems youtube needs to fix their CORS policies and disable doubleclick ads when embedding youtube-nocookie.com links)
