# 🌳 TreeHero

<p align="center">
  <b>2D Farming & Environmental Simulation Game</b><br>
  Built with Godot Engine 4
</p>

---

## 📌 About The Project

**TreeHero** is a 2D farming and environmental simulation game where players restore ecological balance through planting, automation, and resource management.

This project demonstrates clean architecture, modular scene composition, persistent world systems, and scalable inventory logic built using Godot 4.

---

## 🎮 Gameplay Features

### 🌱 Farming System
- Soil preparation  
- Watering mechanics  
- Growth progression  
- Soil aging & regeneration  

### 💰 Inventory & Economy
- Item-based tracking system  
- Coin economy  
- Centralized item mutation logic  
- Backward-compatible inventory schema  

### 🛠 Automation System
- Sprinkler  
- Fisher  
- Scarecrow  
- Build & delete logic  

### 🌦 Dynamic Systems
- Weather cycle (Rain)  
- Day progression system  
- Growth influenced by environmental conditions  

### 🏪 Interaction System
- Dialog interaction  
- Shop system  
- Real-time resource UI updates  

### 💾 Persistent Save System
- Player state serialization  
- Inventory encoding/decoding  
- Plant & machine reconstruction  
- Merge strategy for backward compatibility  

---

## 🧠 Architecture Overview

### Global State Layer  
`global/data.gd`

- Centralized game variables  
- Inventory management  
- Economy handling  
- Day progression tracking  

### Enumeration Layer  
`global/enum.gd`

Strongly typed enums for:
- Items  
- Tools  
- Seeds  
- Machines  
- Shops  
- Player states  

### Save System  
`global/save_manager.gd`

Handles:
- World serialization  
- Safe inventory restoration  
- Environment state persistence  

---

## 📂 Project Structure

```text
gv_start_project/
│
├── Asset/
├── audio/
├── graphics/
├── shaders/
│
├── global/
│   ├── data.gd
│   ├── enum.gd
│   └── save_manager.gd
│
├── scenes/
│   ├── objects/
│   ├── machines/
│   ├── ui/
│   └── levels/
│
├── resources/
├── MainMenu/
├── Option_Tutorial/
├── premade/
│
├── export_presets.cfg
└── README.md
```

---

## ⚙️ Tech Stack

| Component | Technology |
|------------|------------|
| Engine | Godot 4.x |
| Language | GDScript |
| Rendering | 2D Pixel |
| Data Persistence | JSON Serialization |
| Architecture | Modular Scene Composition |

---

## 🚀 Getting Started

1. Install **Godot Engine 4.x**  
2. Clone the repository  
   ```bash
   git clone <repository-url>
   ```
3. Open `gv_start_project` in Godot  
4. Run the main scene  

---

## 💽 Save File Location

### Windows
```text
C:\Users\USERNAME\AppData\Roaming\Godot\app_userdata\TreeHero\
```

### macOS
```text
~/Library/Application Support/Godot/app_userdata/TreeHero/
```

---

## 🛣 Roadmap

- External JSON-based dialog system  
- Advanced economy balancing  
- Achievement tracking  
- Mobile export optimization  
- Extended automation mechanics  

---

## 📜 License

Developed for educational and portfolio purposes.
