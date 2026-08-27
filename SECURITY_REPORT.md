# OSCAR Security Evaluation & Hardening Report

## Executive Summary

This report presents an in-depth security evaluation of the Open Source Central Alarm Station (OSCAR) application, a radiation portal monitoring software designed to aggregate and process Gamma (G) and Neutron (N) alarm data. Given the critical nature of its primary function—detecting and alerting on radiological and nuclear threats—the core security imperative is to guarantee the **integrity, availability, and non-repudiation** of G/N alarm data.

The application architecture utilizes a Java-based processing engine (SensorHub/OSCAR), a PostgreSQL/PostGIS backend for persistence, and an Nginx TLS gateway for front-end access, containerized via Docker Compose. The evaluation reveals several strengths, such as the use of PBKDF2 for password hashing and the intention to use TLS. However, significant vulnerabilities were identified, particularly around potential unsafe deserialization, command injection, and lack of rigorous internal micro-segmentation. If exploited, these vulnerabilities could lead to unauthorized modification, delay, or suppression of critical G/N alarms.

This report outlines topology-specific threat models to address the five targeted deployment scenarios and provides actionable hardening artifacts to mitigate identified risks, focusing on least privilege, network isolation, and secure configuration.

---

## Topology-Specific Threat Models

### 1. Federated Site-to-Site (Tailscale)
**Context:** Multiple sites federated using a Tailscale mesh network.
**Threat Vectors:**
1. **Compromised Tailnet Node (Lateral Movement & Spoofing):** If a node within the Tailnet is compromised, an attacker could attempt to spoof G/N alarms or inject false telemetry data (e.g., through `EMLService` or `RapiscanSensor` interfaces) into other federated nodes. The application must not implicitly trust all traffic on the Tailscale interface; it requires strict Layer 7 authentication (mutual TLS or strong API keys) on top of Tailscale's Layer 4 WireGuard encryption.
2. **Cross-Site State Synchronization Manipulation:** An attacker on the Tailnet could intercept or manipulate state synchronization traffic, causing delays or suppression of critical alarm notifications across sites.

### 2. Fully Offline / Air-Gapped Single Node
**Context:** Deployed on isolated hardware at a physical site with zero external network connectivity.
**Threat Vectors:**
1. **Physical / Local Privilege Escalation:** An attacker with physical access to the device or local network could exploit vulnerabilities like command injection (e.g., in `KrakenUTILITY.java`) or insecure deserialization (e.g., `Serializer.java` or `XStream`) to gain root access to the Docker host, allowing them to disable the OSCAR service or tamper with the PostgreSQL database.
2. **Local Data-at-Rest Tampering:** Without strong data-at-rest encryption and access controls, a local attacker could directly modify the PostgreSQL database or the `secrets/` directory to suppress historical alarm data or extract administrative credentials.

### 3. Shared Physical Security Network
**Context:** A single node deployed on a local network shared with other physical security systems (CCTV, access control).
**Threat Vectors:**
1. **Lateral Movement from Weak Devices:** Other devices on the shared network (like IoT cameras or access control panels) are often less secure. If compromised, an attacker could pivot to the OSCAR node. The application currently relies on a `docker-compose` network, but the host might be exposed to the local subnet, allowing an attacker to interact with the API or PostgreSQL port if not properly firewalled.
2. **Denial of Service (DoS) / Broadcast Storms:** A compromised or misconfigured device on the shared network could generate a broadcast storm or targeted DoS attack against the OSCAR node, causing resource exhaustion and delaying the processing of incoming G/N alarms.

### 4. Single Site Network with Internet Access
**Context:** A standard LAN deployment where the node has outbound (and potentially inbound) Internet access.
**Threat Vectors:**
1. **Supply Chain & Outbound C2 Beaconing:** If the application or its dependencies contain vulnerabilities (e.g., insecure deserialization), an attacker could compromise the node and establish an outbound Command & Control (C2) connection. This could be used to exfiltrate alarm data or remotely disable the system.
2. **Remote Management Exposure:** If the remote management interface or the Nginx gateway is exposed to the internet without strict IP whitelisting or MFA, attackers could brute-force credentials or exploit web vulnerabilities to gain administrative access and suppress alarms.

### 5. Network with Wireless Access Points (WAPs)
**Context:** Deployed on a network where operators or devices connect via Wi-Fi.
**Threat Vectors:**
1. **Wireless Packet Sniffing (Man-in-the-Middle):** If traffic between wireless clients and the OSCAR node is not strictly encrypted (e.g., using WSS instead of WS, or HTTPS instead of HTTP), an attacker in physical proximity could sniff session tokens or alarm data.
2. **Session Hijacking & Token Interception:** An attacker intercepting a valid operator's session token over the wireless network could use it to log into the web interface, acknowledging or clearing G/N alarms maliciously.

---

## Vulnerability Findings

### 1. Unsafe Deserialization (Java ObjectInputStream)
* **Severity:** High
* **Description:** The codebase uses `java.io.ObjectInputStream` for deserializing objects, specifically in `Serializer.java` (`gov.llnl.utility.Serializer`). If this utility is used to process untrusted data (e.g., configuration files, network streams, or uploaded files), it is vulnerable to arbitrary code execution.
* **File/Line References:**
    * `include/osh-oakridge-modules/EML-VM250-v0.9.1/src/gov.llnl.utility/src/public/gov/llnl/utility/Serializer.java`
* **Exploit Scenario:** An attacker provides a maliciously crafted serialized Java object to an endpoint or file upload mechanism that uses `Serializer.java`. When the application deserializes the object, it executes arbitrary code, leading to a complete system compromise and the ability to manipulate G/N alarms.
* **Remediation:** Replace `ObjectInputStream` with a safe alternative like Jackson or Gson for data binding, or implement strict look-ahead object input streams (e.g., `ValidatingObjectInputStream`) that only allow specific, safe classes to be deserialized.

### 2. Unsafe Deserialization (XStream)
* **Severity:** High
* **Description:** The `sensorhub-zwave-comms` module includes a dependency on `com.thoughtworks.xstream:xstream:1.4.20`. XStream is known to be vulnerable to unsafe deserialization if not explicitly configured with strict security frameworks to restrict the types of objects it can instantiate.
* **File/Line References:**
    * `include/osh-oakridge-modules/sensors/zwave/sensorhub-zwave-comms/build.gradle`
* **Exploit Scenario:** If the Z-Wave communication module processes untrusted XML/JSON payloads from the network or devices using an unconfigured XStream instance, an attacker could achieve Remote Code Execution (RCE).
* **Remediation:** Ensure XStream is configured with `XStream.setupDefaultSecurity(xstream)` and explicitly allow only required classes using `xstream.allowTypes(...)`. Alternatively, migrate to a safer serialization library.

### 3. Command Injection Risk via ProcessBuilder
* **Severity:** Medium
* **Description:** The application uses `ProcessBuilder` to execute a `curl` command for uploading settings, passing a potentially user-controllable `OUTPUT_URL` without apparent sanitization.
* **File/Line References:**
    * `include/osh-addons/sensors/detection/sensorhub-driver-krakenSDR/src/main/java/org/sensorhub/impl/sensor/krakenSDR/KrakenUTILITY.java` (lines 80-84)
* **Exploit Scenario:** If an attacker can manipulate the `OUTPUT_URL` parameter (e.g., through a configuration API), they could inject arbitrary command-line arguments to the `curl` command, potentially leading to unauthorized file reads or execution of unintended actions.
* **Remediation:** Avoid using `ProcessBuilder` with external utilities like `curl` for HTTP requests. Instead, use native Java HTTP clients (e.g., `java.net.http.HttpClient` or Apache HttpClient) to perform the upload, which completely eliminates the command injection risk.

### 4. Hardcoded Credentials in Test/Configuration Files
* **Severity:** Low
* **Description:** Hardcoded credentials (e.g., `root`/`password`) are present in test CSV files used for lane configuration and spreadsheet parsing. While these are in test files, their presence indicates a risk that such files might be accidentally deployed or used as templates in production.
* **File/Line References:**
    * `include/osh-oakridge-modules/services/sensorhub-service-oscar/src/test/resources/spreadsheets/1-camera.csv`
* **Exploit Scenario:** If an administrator uses these test CSV files as a baseline for configuring a production system, default passwords may be inadvertently deployed, allowing attackers to access connected cameras or systems.
* **Remediation:** Remove hardcoded passwords from repository files. Provide documentation on how to securely inject credentials (e.g., using Docker secrets or environment variables) during configuration.

### 5. Inadequate Docker Container Hardening
* **Severity:** Medium
* **Description:** The default `Dockerfile` for the `oscar` service drops all capabilities (`cap_drop: ALL` in `compose.yaml`), which is excellent. However, the Dockerfile runs as a non-root user (`oscar`), but does not explicitly leverage read-only root filesystems or robust seccomp profiles to the fullest extent within the `Dockerfile` itself.
* **File/Line References:**
    * `dist/release/docker/oscar/Dockerfile`
    * `dist/release/compose.yaml`
* **Exploit Scenario:** If an RCE vulnerability (like the deserialization issues mentioned above) is exploited, the attacker has a read-write filesystem within the container, making it easier to download secondary payloads or modify local configurations.
* **Remediation:** Enforce a read-only root filesystem (`read_only: true` in `compose.yaml` is present, but ensure temporary directories are strictly mapped to `tmpfs`). Ensure the `fonts-freefont-ttf` package is installed for necessary rendering without requiring extra privileges.
