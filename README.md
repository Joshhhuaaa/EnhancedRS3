A major patch for Rainbow Six 3, fixing bugs and adding gameplay improvements.

For a full list of patch notes, refer to the [Patch Notes](PatchNotes.md) page.

If you'd like to donate, all contributions are appreciated.
<div align="left">
  <a href="https://www.paypal.com/donate/?hosted_button_id=UB67N4GNTCEZ6">
    <img src="https://github.com/user-attachments/assets/6a8878e8-3ae8-48e5-8d2a-ae367c71df10" width="256" alt="PayPal"/>
  </a>
</div>

## Installation
The latest version of Enhanced RS3 can be found on the [Releases](https://github.com/Joshhhuaaa/EnhancedRS3/releases) page.

### Game Setup
- After downloading Enhanced RS3, extract the contents to your Rainbow Six 3 directory and overwrite all existing files when prompted.
- You can adjust additional settings in `EnhancedRS3.ini` located in the `system\plugins` folder.

## Uninstallation
- Navigate to the `system` folder, delete the `plugins` folder, `d3d8.dll`, and `dinput8.dll`.

## Features
### Skip Intro
Skips the Ubisoft, Red Storm Entertainment, and intro videos for a faster launch into the game.

### Widescreen Support
In the stock game, menus and cutscenes are hardcoded to render at 640x480, while the HUD stretches at widescreen aspect ratios. Enhanced RS3 renders menus and cutscenes at the in-game resolution and dynamically scales HUD elements to maintain their original proportions at any resolution.

Field of view is calculated automatically based on the aspect ratio, widening the horizontal FOV while preserving the vertical FOV from 4:3.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/3e3145ec-ec33-4413-a376-d3f675d266f8"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/fc601135-b39d-4558-9945-ca6f1e8c5297"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Enhanced</td>
    </tr>
  </table>
</div>

### Raw Input
Mouse input accurately reads data at high polling rates, eliminating the need to cap the mouse at 125 Hz. Adds support for Mouse 4 and 5 side buttons.

### Mouse Sensitivity Multiplier
Separate sensitivity multipliers for in-game aiming and the menu cursor allow for more control than the in-game slider.

### Borderless Support
Adds an option to run the game in borderless windowed mode. Borderless always renders at the native resolution, regardless of the in-game resolution setting.

### Anisotropic Filtering
Forces anisotropic texture filtering.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/a1f0d485-43e2-47e5-9130-aa6632271095"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/7d44b9c1-7ae1-4c13-bf8f-a48283e076b7"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Anisotropic 16x</td>
    </tr>
  </table>
</div>

### Subpixel Morphological Antialiasing (SMAA)
Enables SMAA to smooth jagged edges.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/286cb783-44f7-4183-a261-504e2a9ac9d3"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/785fb874-3209-46b5-8aef-addcc202f720"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">SMAA</td>
    </tr>
  </table>
</div>

### Center Optics
Some optics are slightly misaligned with the center crosshair in the stock game. Corrects their position to better align them with the center of the screen.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/bb0c39ec-6839-40e1-86fb-86916a6b0aec"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/53238ed6-c076-467e-b263-1e612e774128"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Center Optics</td>
    </tr>
  </table>
</div>

### Hide Crosshair When Zoomed
Hides the crosshair while zoomed, either hiding only the center dot or the entire crosshair.

<div align="center">
  <table>
    <tr>
      <td width="33.33%"><img style="width:100%" src="https://github.com/user-attachments/assets/53238ed6-c076-467e-b263-1e612e774128"></td>
      <td width="33.33%"><img style="width:100%" src="https://github.com/user-attachments/assets/0ee9d9a8-70db-428d-93db-e8eea15667de"></td>
      <td width="33.33%"><img style="width:100%" src="https://github.com/user-attachments/assets/6e992b0d-216a-4530-b416-01e1e1acba43"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Hide Center Dot</td>
      <td align="center">Hide Crosshair</td>
    </tr>
  </table>
</div>

### Framerate Limiter
Sets a maximum framerate. A value of `0` disables the limiter, `-1` matches the monitor's refresh rate, and any other value enables a hard cap at that value.

### Multiplayer
- Net speed is forced to 480 kbps (24x the stock T1/T3 limit), providing plenty of bandwidth headroom for higher FPS. The in-game Connection Type setting is ignored, preventing a misconfigured setting from bottlenecking the connection.
- Fixed an issue that caused hosting an online game session to freeze every 15 seconds as the server attempted to register with Ubi.com's master server.

### Bug Fixes
- Fixed the long delay when making selections during the Planning Phase or in UnrealEd on modern hardware.
- Fixed crashes that could occur when alt-tabbing out of the game while in fullscreen, particularly when an overlay such as RivaTuner was hooked.
- Fixed weapon zoom snapping in instantly at high framerates. The FOV transition is now smooth and consistent at any framerate.
