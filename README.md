# Solaar Battery Widget

[English](#english) | [Deutsch](#deutsch)

---

## English

A KDE Plasma 6 system tray widget (plasmoid) that displays the battery levels of wireless Logitech devices tracked by Solaar.

### What is it for?

The Solaar Battery Widget allows you to monitor the battery levels of your Logitech devices (e.g., Lightspeed mice, keyboards, headsets) directly in the KDE panel without having to open the Solaar GUI.

#### Key Features:
- **Smart Taskbar Icon**: The widget icon in the taskbar always displays a battery icon representing the device with the **lowest battery level**.
- **Visual Warning**: If any device's battery capacity drops below **20%**, the taskbar icon automatically turns **red**.
- **Audio Warning**: When a device drops below 20%, a subtle warning sound is played once. This ensures you are notified even during intense gaming sessions or when in full-screen mode.
- **Detailed Overview**: Clicking the widget opens a popup window showing a list of all connected devices, their current battery status (including charging state), and a progress bar.

### Prerequisites

- **KDE Plasma 6**
- **Solaar** (installed and in your PATH)
- **Python 3**
- **canberra-gtk-play**, **pipewire** (`pw-play`), or **pulseaudio** (`paplay`) (for audio notifications)

### Installation

You can install the widget using the packaged `.plasmoid` file:

```bash
kpackagetool6 --type Plasma/Applet -i com.github.solaarwidget.plasmoid
```

To update an already installed widget:

```bash
kpackagetool6 --type Plasma/Applet -u com.github.solaarwidget.plasmoid
```

---

## Deutsch

Ein KDE Plasma 6 Systemabschnitt-Widget (Plasmoid), das die Akkustände von kabellosen Logitech-Geräten anzeigt, die über Solaar verwaltet werden.

### Wofür ist es gut?

Das Solaar Battery Widget ermöglicht es dir, die Akkustände deiner Logitech-Geräte (z. B. Lightspeed-Mäuse, Tastaturen, Headsets) direkt im KDE-Panel im Blick zu behalten, ohne die Solaar-GUI öffnen zu müssen.

#### Hauptfunktionen:
- **Intelligentes Taskleisten-Symbol**: Das Widget-Symbol in der Taskleiste zeigt immer ein Akkusymbol an, das sich grafisch nach dem Gerät mit dem **niedrigsten Akkustand** richtet.
- **Optische Warnung**: Sobald eines der Geräte unter **20 % Akkukapazität** fällt, färbt sich das Symbol in der Taskleiste automatisch **rot**.
- **Akustische Warnung**: Fällt ein Gerät unter 20 %, wird einmalig ein dezenter Warnton abgespielt. So wirst du auch während einer intensiven Gaming-Session oder im Vollbildmodus rechtzeitig gewarnt.
- **Detaillierte Übersicht**: Ein Klick auf das Widget öffnet ein Pop-up-Fenster mit einer Liste aller verbundenen Geräte, deren aktuellem Akkustand (inklusive Lade-Status) sowie einem Fortschrittsbalken.

### Voraussetzungen

- **KDE Plasma 6**
- **Solaar** (muss installiert und im Pfad sein)
- **Python 3**
- **canberra-gtk-play**, **pipewire** (`pw-play`) oder **pulseaudio** (`paplay`) (für die Sound-Benachrichtigungen)

### Installation

Du kannst das Widget über die gepackte `.plasmoid`-Datei installieren:

```bash
kpackagetool6 --type Plasma/Applet -i com.github.solaarwidget.plasmoid
```

Um ein bereits installiertes Widget zu aktualisieren:

```bash
kpackagetool6 --type Plasma/Applet -u com.github.solaarwidget.plasmoid
```
