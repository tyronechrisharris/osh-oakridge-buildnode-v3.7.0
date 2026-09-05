# OSCAR System Specification (Enduser Overview)

## What is OSCAR?
OSCAR (Open Source Central Alarm Station) is a comprehensive software system designed to monitor and manage radiation portal monitors. Its primary purpose is to process and alert operators to potential radiation threats, specifically Gamma (G Alarm), Neutron (N Alarm), and combined Gamma-Neutron (G-N) alarms.

## Key Features
* **Real-time Monitoring:** Continuously tracks sensor data to detect radiation events as they happen.
* **Alert System:** Immediately notifies operators of Gamma and Neutron radiation alarms.
* **Geospatial Tracking:** Integrates location data (using a specialized geographic database) to map where alerts are occurring.
* **Secure Access:** Ensures that all monitoring data and system controls are protected through secure, encrypted connections.

## Core System Components
To provide a reliable and secure experience, the OSCAR system is built using several key pieces that work together behind the scenes:

1. **The Brain (Java Backend & SensorHub):** This is the core processing unit. It continuously gathers data from radiation sensors, analyzes it, and triggers alarms when dangerous levels of Gamma or Neutron radiation are detected.
2. **The Dashboard (Web Viewer):** This is the interface you interact with. It is a modern, web-based dashboard that allows operators to view live sensor data, acknowledge alarms, and visualize the location of events on a map.
3. **The Memory (PostgreSQL/PostGIS Database):** This is where all the system's data is safely stored. It records historical sensor readings, alarm events, and geographic information so operators can review past incidents and track trends over time.
4. **The Security Guard (Nginx Secure Gateway):** This component stands between the outside world and the OSCAR system. It ensures that all communication is encrypted (using HTTPS) and blocks unauthorized access, keeping sensitive monitoring data safe.

## User Experience
For the enduser, OSCAR provides a seamless and secure web interface. Operators can log in from standard web browsers to monitor radiation portals, receive immediate visual and auditory alerts when threats are detected, and review historical data—all without needing to understand the complex backend machinery processing the sensor data.