# Setting Up a Radiation Portal Monitor (RPM) Lane in OSCAR

This guide will walk you through the process of setting up a new Radiation Portal Monitor Lane using the Lane System driver in the OSCAR Admin interface. You can set up a lane manually using the UI forms, or in bulk using a CSV Spreadsheet.

## Method A: Manual Setup via Admin UI

### Step 1: Add a New Lane System Driver
1. Log into the OSCAR Admin UI.
2. Select **Sensors** from the left-hand accordion control.
3. Right-click inside the accordion control to open the context-sensitive menu.
4. Click **Add New Module** and select **Lane System** from the list of available modules.

### Step 2: Configure the Lane Details (General Tab)
In the configuration form that appears, fill out the General settings:
1. **Module Name:** Give your lane a unique name (must be less than 12 characters).
2. **UniqueID:** Provide the platform's serial number or a unique identifier. This will be used for all submodules and must be unique.
3. **Auto Start:** Check this box to ensure the module starts automatically when the OSH node is launched.
4. **Delete Data on Lane Removal:** Check this box if you want the system's data to be removed from the database if the lane is deleted.
5. **Fixed Location:** Provide the **Latitude** and **Longitude** for the lane's location.

### Step 3: Select the Radiation Portal Monitor (RPM) Type
Scroll to the **Lane Options Config** section to set up your RPM:
1. Under **Initial RPM Config**, click **Add**.
2. Select your RPM type from the available options (e.g., **Rapiscan**, **Aspect**, or **RS350**).
3. Configure the specific RPM settings:
   - For **Rapiscan** and **Aspect**: Provide the **Remote Host** (IP address) and **Remote Port** of the device.
   - For **Aspect** (Additional): Provide the **Address Range**.

### Step 4: Add Cameras
Still under the **Lane Options Config** section, you will link cameras:
1. Under **Initial Camera Config**, click **Add**.
2. Select the camera type: **Sony**, **Axis**, or **Custom** (for RTSP URLs).
3. Configure the camera settings:
   - **Remote Host:** Enter your camera's IP and port in the format `ip.ip.ip.ip:port` (e.g., `192.168.8.77:8554`).
   - **Username:** Enter your camera's username (if applicable).
   - **Password:** Enter your camera's password (if applicable).
   - **Axis (Specific):** Select the **Stream Codec**.
   - **Custom (Specific):** In the **Stream Path** field, enter everything that comes after the IP and port in your stream URL (e.g., `/lane04_cam`).
4. Repeat this process for any additional cameras you wish to add to the lane.

### Step 5: Apply Changes and Initialize
1. Once all general details, RPM configurations, and camera configurations are filled out, click the **Apply** button at the bottom of the form to save the configuration to the database.
2. Next, right click the new module you created under the **Sensors** list.
3. Click the **Initialize** option. The system will attempt to establish connections to the RPM hardware and the configured cameras based on your settings.

### Step 6: Confirm Sensor Initialization and Start
1. Watch the status indicator next to the Lane System driver in the left-hand menu. It should turn yellow, indicating it is **Initialized**.
2. If it initialized successfully, right-click the module again and click **Start**.
3. The indicator should turn green, indicating the Lane System is now actively pulling data and running.

---

## Method B: Bulk Setup via CSV Import / Export

If you have multiple lanes to configure, you can import their configurations directly using a CSV spreadsheet file. This process uses the OSCAR Spreadsheet Handler to automatically create and load the Lane System drivers.

### Exporting Current Configurations (CSV Export)
To see the required CSV format or to backup your existing lanes:
1. Navigate to the area in the OSCAR Admin UI or OSCAR API responsible for downloading the configuration spreadsheet.
2. The system generates a serialized CSV containing all currently loaded `LaneSystem` modules.
3. The file is saved internally to the `spreadsheets` bucket as `config.csv` and served as a download.
4. You can open this CSV in Excel or any text editor to view the structure of the lane configurations (including UniqueIDs, locations, RPMs, and cameras).

### Importing New Configurations (CSV Import)
1. Prepare a `.csv` file detailing your new lanes. Ensure the format matches the exported template.
   - *Note:* The importer will automatically skip any lanes in the CSV that share a `UniqueID` with an already existing lane in the system.
2. Upload the `.csv` file via the OSCAR Admin UI file upload tool (or the designated spreadsheet upload endpoint).
3. The system will automatically process the CSV file.
4. For every new lane found, it will:
   - Create the module configuration.
   - Add it to the **Sensors** list.
   - Attempt to initialize and start the module asynchronously.
5. Check your **Sensors** list in the Admin UI to verify that the new lanes have been loaded, initialized, and started.

---

## Final Step: View the System in OSCAR Viewer
Regardless of whether you used Method A or Method B:
1. Open a new browser tab and navigate to the **OSCAR Viewer** application.
2. From the main dashboard, you should see your newly created lane(s) listed.
3. Click on the lane or navigate to the Lane View to observe the live data charts for radiation readings and the live video feeds from the cameras you configured.