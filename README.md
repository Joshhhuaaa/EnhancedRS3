# Enhanced RS3

A patch for Rainbow Six 3, fixing bugs and adding gameplay improvements.

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
To manually remove Enhanced RS3 from your game installation:
- Navigate to the `system` folder, delete the `plugins` folder, `d3d8.dll`, and `winmm.dll`.

This patch also includes [OpenRVS](https://github.com/OpenRVS-devs/OpenRVS).

#### OpenRVS
- Delete `OpenRVS.u`, `openrvs.ini`, `OpenRenderFix.u`, and `Servers.list`.
- Delete `R6ClassDefines.ini`, then rename `R6ClassDefines.ini.bak` to `R6ClassDefines.ini`.

## Features
### Skip Intro
Skips the Ubisoft, Red Storm Entertainment, and intro videos for a faster launch into the game.

### Widescreen Support
In the stock game, menus and cutscenes are hardcoded to render at 640x480, while the HUD stretches at widescreen aspect ratios. Enhanced RS3 renders menus and cutscenes at the in-game resolution and dynamically scales HUD elements to maintain their original proportions at any resolution. Text is drawn from the game's larger font sizes instead of being stretched, keeping it sharp at high resolutions.

Field of view is calculated automatically based on the aspect ratio, widening the horizontal FOV while preserving the vertical FOV from 4:3. `FieldOfView` in the ini can turn this off for the stock projection, or force a specific horizontal FOV instead.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/3e3145ec-ec33-4413-a376-d3f675d266f8"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/94814bb3-8d0b-448e-beab-91db6a157e91"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Enhanced</td>
    </tr>
  </table>
</div>

### Font Scaling
The game's text uses small bitmap fonts, which turn blurry when stretched to fit higher resolutions. Enhanced RS3 draws text from the game's larger font sizes instead, keeping the HUD, menus, and console sharp at any resolution. The console also uses the HUD's font in place of the stock one, which only comes in a single small size.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/27edcaa4-4518-40cf-96a6-aaa1bec82f47"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/ce8db653-5583-4671-a9e6-d2fb3513a542"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Enhanced</td>
    </tr>
  </table>
</div>

### HUD Artifacting
At resolutions above 640x480, HUD and menu elements show thin dark lines along their edges, caused by neighboring parts of their texture bleeding in as they scale up. Enhanced RS3 keeps these edges clean at any resolution.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/9a3c3c55-5159-4c54-843b-0c4340dc536d"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/e726446a-09dd-4c1b-b1b5-549b899f4f9a"></td>
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
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/7d44b9c1-7ae1-4c13-bf8f-a48283e076b7"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/a1f0d485-43e2-47e5-9130-aa6632271095"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Anisotropic 16x</td>
    </tr>
  </table>
</div>

### Multisample Antialiasing (MSAA)
Enables MSAA to smooth jagged edges while preserving a sharp image. MSAA does not smooth alpha-tested edges such as fences and foliage.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/4ec1aab5-ced4-413b-8bb9-2eb3b893db7d"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/e23ba662-9a50-4330-afd1-2a7224e1e5a4"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">MSAA 8x</td>
    </tr>
  </table>
</div>

### Subpixel Morphological Antialiasing (SMAA)
Enables SMAA to smooth jagged edges with a softer image. SMAA also smooths alpha-tested edges such as fences and foliage.

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

### Shadow Resolution
Allows shadow resolution to be increased from the stock 128x128 up to 2048x2048 for sharper shadows. `ShadowDetail` in the ini controls whether higher resolutions sharpen the shadow for more detail or keep the stock softness.

<div align="center">
  <table>
    <tr>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/317c95d5-8214-4a31-a9d5-48410fbb666b"></td>
      <td width="50%"><img style="width:100%" src="https://github.com/user-attachments/assets/061d1883-dec4-461b-a9af-121c2cdd117f"></td>
    </tr>
    <tr>
      <td align="center">Stock</td>
      <td align="center">Enhanced</td>
    </tr>
  </table>
</div>

### EAX Audio Support
Allows local DirectSound wrappers such as ALchemy and [DSOAL](https://github.com/kcat/dsoal) to load correctly, enabling EAX audio without requiring a registry change. DSOAL is included with the patch.

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
- Ubisoft discontinued Raven Shield's servers in 2016. [OpenRVS](https://github.com/OpenRVS-devs/OpenRVS) is included to restore online play, replacing the Ubi.com server browser with a new server list and removing the Ubi.com login and CD key checks. Servers can also be joined directly by IP address.
- Fixed an issue that caused hosting an online game session to freeze every 15 seconds as the server attempted to register with Ubi.com's master server.

### Bug Fixes
- Fixed the long delay when making selections during the Planning Phase or in UnrealEd on modern hardware.
- Fixed crashes that could occur when alt-tabbing out of the game while in fullscreen, particularly when an overlay such as RivaTuner was hooked.
- Fixed weapon zoom snapping in instantly at high framerates. The FOV transition is now smooth and consistent at any framerate.
- Fixed a bug where the player's own shadow would disappear after pausing or restarting a level.
