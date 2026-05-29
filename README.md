# 🕒 Multi-Module 24-Hour Alarm Clock on Basys 3

A clean, modular Verilog implementation of a 24-hour real-time clock and programmable alarm system optimized for the **Digilent Basys 3 FPGA Artix-7 Development Board**. 

This project features independent real-time and alarm register modules, synchronous debounced button controls, an audio-driven passive buzzer playing a custom melody, and a time-multiplexed 7-segment display.

---

## 📐 Hardware Architecture & Schematics
The system is divided into clear functional blocks to optimize synthesized RTL routing layers:
