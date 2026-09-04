# Setting Up a Radiation Portal Monitor (RPM) Lane in OSCAR

This guide will walk you through the process of setting up a new Radiation Portal Monitor Lane using the Lane System driver in the OSCAR Admin interface, from initial configuration to viewing the live lane in the OSCAR Viewer.

## Step 1: Add a New Lane System Driver
1. Log into the OSCAR Admin UI.
2. Navigate to the **Sensor Management** or **Drivers** section.
3. Click on the option to **Add a New Driver** or **Add Sensor**.
4. From the list of available driver types, select the **Lane System Driver** (or similar designation for the aggregated lane system).

## Step 2: Configure the Lane Details
1. Give your new lane a descriptive **Name** (e.g., "Main Entrance Lane 1").
2. Provide a **Description** outlining its location or purpose.

## Step 3: Select the Radiation Portal Monitor (RPM) Type
Within the Lane System configuration panel, you must specify the primary radiation monitor hardware being used for this lane:
1. Locate the **RPM Type** dropdown or selection menu.
2. Select the specific brand/model of your RPM. Common options include:
   - **Rapiscan**
   - **Aspect**
   - **RS350**
3. Fill in any required connection details for the chosen RPM (such as IP address or COM port) as prompted by the configuration form.

## Step 4: Add Cameras
Next, you will link cameras to the lane to provide visual context for alarm events.
1. Locate the **Cameras** section within the Lane System configuration.
2. Click **Add Camera**.
3. Select the camera type:
   - **Sony:** Select this if using a supported Sony camera model and provide the IP/credentials.
   - **Axis:** Select this if using a supported Axis camera model and provide the IP/credentials.
   - **RTSP / Custom URL:** Select this if you are connecting to a generic IP camera stream. You will need to enter the exact RTSP URL (e.g., `rtsp://username:password@camera-ip:554/stream`).
4. Repeat this process for each camera associated with the lane (e.g., front view, rear view, overview).

## Step 5: Apply Changes and Initialize
1. Once you have configured the lane details, RPM type, and all cameras, click the **Apply** or **Apply Changes** button. This saves the configuration to the database.
2. Next, click the **Initialize** button. This instructs the OSCAR system to attempt connections to the RPM hardware and the configured cameras based on the settings you just provided.

## Step 6: Confirm Sensor Initialization
1. After clicking Initialize, watch the status indicators or log output in the Admin UI.
2. Ensure that the main Lane driver, the RPM component, and every camera component reports a status of **Initialized** or **Connected**.
3. *Troubleshooting:* If any component fails to initialize (e.g., an RTSP camera shows an error), verify the IP addresses, passwords, and network connectivity before proceeding.

## Step 7: Start the Driver and Save
1. Once all components are successfully initialized, click the **Start** button. This tells the driver to begin actively pulling data (radiation readings and video streams) from the hardware.
2. The status should change to **Running** or **Active**.
3. Finally, ensure you click **Save** (if separate from Apply) to persist this running configuration so it starts automatically if the OSCAR server reboots.

## Step 8: View the System in OSCAR Viewer
1. Open a new browser tab and navigate to the **OSCAR Viewer** dashboard.
2. In the Viewer interface, navigate to the **Lane View** or locate your newly created lane on the Dashboard.
3. You should now see:
   - Live data charts (Gamma/Neutron readings) if the RPM is transmitting data.
   - Live video feeds from the cameras you configured.
   - The lane's status reflecting "Online" and ready to process occupancies or alarms.
