<div align="center">
  <img src="assets/banner1.png" alt="Photo Ripple Banner" width="100%">
  
  # Photo Ripple 🌊
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](LICENSE)
</div>

---

## 🚀 Project Description

**Photo Ripple** is a high-performance Flutter application that creates mesmerizing, interactive liquid ripple effects on images. Powered by custom **GLSL shaders** (`.frag`) and Flutter's **FragmentProgram**, creates a realistic water distortion effect that responds to user touch. 

Designed with a sleek, dark-themed UI and smooth 60fps animations, it showcases the power of Flutter for advanced visual effects.

---

## 📸 Demo

<div align="center">
  <img src="assets/promotion.gif" alt="App Demo" width="300">
</div>

---

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (Dart)
*   **Rendering**: CustomPainter & Shaders (GLSL)
*   **Typography**: Inter (Google Fonts)
*   **Architecture**: Component-based UI

---

## ✨ Features

*   **💧 Interactive Ripple Effect**: Tap anywhere on the image to spawn organic, expanding ripples.
*   **⚡ Shader Powered**: Uses hardware-accelerated GLSL shaders for silky smooth performance.
*   **🎨 Aesthetic UI**: Minimalist dark mode design with premium typography.
*   **👆 Multi-touch Support**: Handles rapid touches efficiently.
*   **📱 Responsive**: Adapts to different screen sizes and aspect ratios.

---

## 🔮 Future Enhancements

*   [ ] **Custom Image Picker**: Allow users to upload their own photos.
*   [ ] **Ripple Customization**: Sliders to control wave speed, frequency, and strength.
*   [ ] **Video Export**: Record and save the ripple animation as a video/GIF.
*   [ ] **Gyroscope Support**: Move the water by tilting the device.

---

## 📦 Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Akarshjha03/Flutter-Ripple-Effect.git
    ```

2.  **Navigate to the project directory**:
    ```bash
    cd flutter_ripple_effect
    ```

3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 🔗 Release

Download the latest release [v1.0.0](https://github.com/Akarshjha03/Flutter-Ripple-Effect/releases/tag/v1.0.0).

---

## 🧩 Usage as UI Component

You can easily use the `RipplePainter` in your own Flutter projects:

```dart
// Import the necessary files
import 'shaders/ripple.frag'; 

CustomPaint(
  painter: RipplePainter(
    program: _program!, // Your loaded FragmentProgram
    image: _image!,     // dart:ui Image
    ripples: _ripples,  // List of ripple objects
    time: _elapsedTime, // Current animation time
  ),
  size: Size(width, height),
)
```

---

<div align="center">
  Made with ❤️ by Akarsh
</div>
