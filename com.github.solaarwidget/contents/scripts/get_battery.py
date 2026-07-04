#!/usr/bin/env python3
import sys
import subprocess
import json
import re
import os

def parse_solaar_show(text):
    devices = []
    current_device = None
    
    lines = text.split('\n')
    for line in lines:
        line_stripped = line.strip()
        
        # Match Codename: <name>
        codename_match = re.match(r'^Codename\s*:\s*(.+)$', line_stripped, re.IGNORECASE)
        if codename_match:
            # If we already have a device, save it before starting the new one
            if current_device:
                devices.append(current_device)
            current_device = {
                'name': codename_match.group(1).strip(),
                'battery': 'Unbekannt'
            }
            continue
            
        # Match Battery: <status>
        battery_match = re.match(r'^Battery\s*:\s*(.+)$', line_stripped, re.IGNORECASE)
        if battery_match and current_device:
            current_device['battery'] = battery_match.group(1).strip()
            continue
            
    if current_device:
        devices.append(current_device)
        
    return devices

def main():
    sample_file = "/home/vmtests/SolaarWidget/sample_output.txt"
    mock_file = "/home/vmtests/SolaarWidget/mock_solaar.txt"
    
    text = ""
    error_msg = None
    
    if os.path.exists(sample_file):
        try:
            with open(sample_file, 'r') as f:
                text = f.read()
        except Exception as e:
            error_msg = f"Fehler beim Lesen der sample_output.txt: {str(e)}"
    elif os.path.exists(mock_file):
        try:
            with open(mock_file, 'r') as f:
                text = f.read()
        except Exception as e:
            error_msg = f"Fehler beim Lesen der Mock-Datei: {str(e)}"
            
    if not text and not error_msg:
        try:
            # Run solaar show command with a 15-second timeout (safer for wireless hardware queries)
            result = subprocess.run(['solaar', 'show'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=15)
            
            if result.returncode != 0:
                stderr_text = result.stderr.strip()
                # If the error is just that no devices are connected, it's a normal empty state
                if "No supported device found" in stderr_text or "No device found" in stderr_text:
                    text = "" # Safe, empty list of devices
                else:
                    error_msg = f"Solaar Fehler (Code {result.returncode}): {stderr_text}"
            else:
                text = result.stdout
        except subprocess.TimeoutExpired:
            error_msg = "Zeitüberschreitung bei der Abfrage von Solaar (Timeout nach 15s)."
        except FileNotFoundError:
            error_msg = "Solaar ist nicht installiert. Bitte installieren Sie 'solaar'."
        except Exception as e:
            error_msg = f"Fehler bei der Ausführung von Solaar: {str(e)}"
            
    devices = []
    if text:
        devices = parse_solaar_show(text)
        
    print(json.dumps({
        "devices": devices,
        "error": error_msg
    }))

if __name__ == "__main__":
    main()
