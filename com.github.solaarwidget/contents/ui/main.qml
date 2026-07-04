import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    
    // Properties
    property int lowestBattery: -1
    property bool lowestBatteryCharging: false
    property bool isLoading: false
    property string errorMessage: ""
    property string lastUpdatedTime: "Nie"
    
    // ListModel for devices
    ListModel {
        id: devicesModel
    }
    
    // Tooltip configuration
    toolTipMainText: "Logitech Geräte"
    toolTipSubText: {
        if (root.isLoading && devicesModel.count === 0) {
            return "Aktualisiere Akkustände...";
        }
        if (root.errorMessage) {
            return "Fehler: " + root.errorMessage;
        }
        if (devicesModel.count === 0) {
            return "Keine Geräte verbunden";
        }
        let lines = [];
        for (let i = 0; i < devicesModel.count; i++) {
            let item = devicesModel.get(i);
            let pctText = item.percentage >= 0 ? item.percentage + "%" : "N/A";
            lines.push(item.name + ": " + pctText);
        }
        return lines.join("\n");
    }
    
    // Preferred representation
    preferredRepresentation: compactRepresentation
    
    // Compact representation (e.g. in the panel)
    compactRepresentation: Item {
        implicitWidth: Kirigami.Units.gridUnit * 2
        implicitHeight: Kirigami.Units.gridUnit * 2
        
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing
            
            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: parent.width * 0.8
                Layout.preferredHeight: parent.height * 0.8
                source: {
                    if (devicesModel.count === 0 || root.lowestBattery < 0) {
                        return "preferences-desktop-keyboard-symbolic";
                    }
                    return getBatteryIcon(root.lowestBattery, root.lowestBatteryCharging);
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: plasmoid.expanded = !plasmoid.expanded
        }
    }
    
    // Full representation (popup or desktop widget)
    fullRepresentation: Item {
        implicitWidth: Kirigami.Units.gridUnit * 18
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 6, Math.min(Kirigami.Units.gridUnit * 22, devicesModel.count * Kirigami.Units.gridUnit * 4 + Kirigami.Units.gridUnit * 6))
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing
            
            // Header
            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                
                Kirigami.Icon {
                    source: "preferences-desktop-keyboard-symbolic"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                }
                
                PlasmaComponents.Label {
                    text: "Logitech Akkustand"
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                PlasmaComponents.ToolButton {
                    icon.name: "view-refresh"
                    onClicked: executable.exec()
                    visible: !root.isLoading
                    
                    // Tooltip
                    PlasmaComponents.ToolTip {
                        text: "Aktualisieren"
                    }
                }
                
                PlasmaComponents.BusyIndicator {
                    running: root.isLoading
                    visible: root.isLoading
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                }
            }
            
            // Separator
            Kirigami.Separator {
                Layout.fillWidth: true
            }
            
            // Error Message
            PlasmaComponents.Label {
                text: root.errorMessage
                color: Kirigami.Theme.negativeTextColor
                visible: root.errorMessage !== ""
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            // List / Empty State
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // Empty State
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: devicesModel.count === 0 && !root.isLoading && root.errorMessage === ""
                    spacing: Kirigami.Units.largeSpacing
                    
                    Kirigami.Icon {
                        source: "preferences-desktop-peripherals"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                        Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                        opacity: 0.5
                    }
                    
                    PlasmaComponents.Label {
                        text: "Keine Logitech-Geräte gefunden"
                        opacity: 0.7
                        font.italic: true
                    }
                }
                
                ListView {
                    id: listView
                    anchors.fill: parent
                    model: devicesModel
                    spacing: Kirigami.Units.mediumSpacing
                    clip: true
                    
                    delegate: Rectangle {
                        width: listView.width
                        height: Kirigami.Units.gridUnit * 4
                        radius: 8
                        
                        color: Kirigami.Theme.alternateBackgroundColor
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.mediumSpacing
                            spacing: Kirigami.Units.largeSpacing
                            
                            // Left: Device Type Icon
                            Kirigami.Icon {
                                source: getDeviceIcon(model.deviceType)
                                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                                Layout.preferredHeight: Kirigami.Units.iconSizes.large
                            }
                            
                            // Middle: Name and details
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                PlasmaComponents.Label {
                                    text: model.name
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                PlasmaComponents.Label {
                                    text: model.batteryText
                                    font: Kirigami.Theme.smallFont
                                    opacity: 0.7
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                            
                            // Right: Battery Progress Bar and percentage
                            ColumnLayout {
                                spacing: 4
                                Layout.alignment: Qt.AlignRight
                                
                                RowLayout {
                                    spacing: Kirigami.Units.smallSpacing
                                    Layout.alignment: Qt.AlignRight
                                    
                                    PlasmaComponents.Label {
                                        text: model.percentage >= 0 ? model.percentage + "%" : "N/A"
                                        font.bold: true
                                    }
                                    
                                    Kirigami.Icon {
                                        source: getBatteryIcon(model.percentage, model.isCharging)
                                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                    }
                                }
                                
                                // Custom visual bar
                                Item {
                                    width: Kirigami.Units.gridUnit * 4
                                    height: 8
                                    visible: model.percentage >= 0
                                    Layout.alignment: Qt.AlignRight
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: Qt.rgba(0, 0, 0, 0.15)
                                        border.color: Qt.rgba(1, 1, 1, 0.05)
                                        border.width: 1
                                    }
                                    
                                    Rectangle {
                                        id: fillBar
                                        width: parent.width * (model.percentage / 100)
                                        height: parent.height
                                        radius: 4
                                        
                                        property color stop0: model.isCharging ? "#2ecc71" : 
                                                               (model.percentage <= 20 ? "#e74c3c" : 
                                                               (model.percentage <= 40 ? "#f39c12" : "#2ecc71"))
                                        property color stop1: model.isCharging ? "#27ae60" : 
                                                               (model.percentage <= 20 ? "#c0392b" : 
                                                               (model.percentage <= 40 ? "#d35400" : "#27ae60"))
                                        
                                        gradient: Gradient {
                                            GradientStop {
                                                position: 0.0
                                                color: fillBar.stop0
                                            }
                                            GradientStop {
                                                position: 1.0
                                                color: fillBar.stop1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Footer
            RowLayout {
                Layout.fillWidth: true
                
                PlasmaComponents.Label {
                    text: "Aktualisiert: " + root.lastUpdatedTime
                    font: Kirigami.Theme.smallFont
                    opacity: 0.5
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    // Command execution engine (Data Source)
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            root.isLoading = false;
            let stdout = data["stdout"];
            let stderr = data["stderr"];
            
            if (stderr) {
                console.warn("Solaar script error: " + stderr);
                root.errorMessage = "Skript-Fehler: " + stderr;
                return;
            }
            
            if (!stdout) {
                root.errorMessage = "Keine Daten vom Skript empfangen.";
                return;
            }
            
            try {
                let response = JSON.parse(stdout);
                
                if (response.error) {
                    root.errorMessage = response.error;
                    return;
                }
                
                let devices = response.devices;
                devicesModel.clear();
                
                let minBattery = 100;
                let minBatteryCharging = false;
                let hasDevices = false;
                
                for (let dev of devices) {
                    let parsed = parseBatteryString(dev.battery);
                    devicesModel.append({
                        "name": dev.name,
                        "batteryText": dev.battery,
                        "percentage": parsed.percentage,
                        "isCharging": parsed.isCharging,
                        "deviceType": detectDeviceType(dev.name)
                    });
                    
                    if (parsed.percentage >= 0) {
                        hasDevices = true;
                        if (parsed.percentage < minBattery) {
                            minBattery = parsed.percentage;
                            minBatteryCharging = parsed.isCharging;
                        }
                    }
                }
                
                root.lowestBattery = hasDevices ? minBattery : -1;
                root.lowestBatteryCharging = hasDevices ? minBatteryCharging : false;
                root.errorMessage = "";
                
                // Format update time
                let now = new Date();
                let hours = String(now.getHours()).padStart(2, "0");
                let minutes = String(now.getMinutes()).padStart(2, "0");
                let seconds = String(now.getSeconds()).padStart(2, "0");
                root.lastUpdatedTime = hours + ":" + minutes + ":" + seconds;
            } catch (e) {
                console.error("Failed to parse Solaar output: " + e);
                root.errorMessage = "Parser-Fehler: " + e.message;
            }
        }
        
        function exec() {
            let scriptUrl = Qt.resolvedUrl("../scripts/get_battery.py").toString();
            let scriptPath = decodeURIComponent(scriptUrl.startsWith("file://") ? scriptUrl.substring(7) : scriptUrl);
            let cmd = "python3 " + scriptPath;
            
            // Clean up any stale connection to avoid commands stacking up/locking
            disconnectSource(cmd);
            
            root.isLoading = true;
            connectSource(cmd);
        }
    }
    
    // Auto-update timer
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: executable.exec()
    }
    
    // Run on startup
    Component.onCompleted: {
        executable.exec()
    }
    
    // Helper parsing functions
    function parseBatteryString(batteryStr) {
        let percentage = -1;
        let isCharging = false;
        
        let lowerStr = batteryStr.toLowerCase();
        
        let match = lowerStr.match(/(\d+)%/);
        if (match) {
            percentage = parseInt(match[1]);
        } else {
            if (lowerStr.includes("full")) {
                percentage = 100;
            } else if (lowerStr.includes("high") || lowerStr.includes("good")) {
                percentage = 75;
            } else if (lowerStr.includes("normal") || lowerStr.includes("medium")) {
                percentage = 50;
            } else if (lowerStr.includes("low")) {
                percentage = 20;
            } else if (lowerStr.includes("critical")) {
                percentage = 5;
            } else if (lowerStr.includes("empty")) {
                percentage = 0;
            }
        }
        
        if (lowerStr.includes("charging") || lowerStr.includes("recharging")) {
            isCharging = true;
        }
        
        return {
            "percentage": percentage,
            "isCharging": isCharging
        };
    }
    
    function detectDeviceType(name) {
        let lowerName = name.toLowerCase();
        if (lowerName.includes("mouse") || lowerName.includes("mx master") || lowerName.includes("superlight") || lowerName.includes("anywhere")) {
            return "mouse";
        } else if (lowerName.includes("keyboard") || lowerName.includes("keys") || lowerName.includes("k800") || lowerName.includes("k380") || lowerName.includes("k400")) {
            return "keyboard";
        } else if (lowerName.includes("headset") || lowerName.includes("headphones") || lowerName.includes("h800") || lowerName.includes("g733")) {
            return "audio-headset";
        }
        return "preferences-desktop-peripherals";
    }
    
    function getDeviceIcon(type) {
        if (type === "mouse") return "input-mouse";
        if (type === "keyboard") return "input-keyboard";
        if (type === "audio-headset") return "audio-headset";
        return "preferences-desktop-peripherals";
    }
    
    function getBatteryIcon(percentage, charging) {
        if (percentage === null || percentage === undefined || percentage < 0) {
            return "battery-missing";
        }
        let rounded = Math.round(percentage / 10) * 10;
        let percentageStr = String(rounded).padStart(3, '0');
        
        if (charging) {
            return "battery-charging-" + percentageStr;
        } else {
            return "battery-" + percentageStr;
        }
    }
}
