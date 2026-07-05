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
    script_dir = os.path.dirname(os.path.realpath(__file__))
    repo_dir = os.path.abspath(os.path.join(script_dir, "..", "..", ".."))
    
    sample_paths = [
        "/home/vmtests/SolaarWidget/sample_output.txt",
        os.path.join(repo_dir, "sample_output.txt"),
        os.path.join(os.getcwd(), "sample_output.txt")
    ]
    mock_paths = [
        "/home/vmtests/SolaarWidget/mock_solaar.txt",
        os.path.join(repo_dir, "mock_solaar.txt"),
        os.path.join(os.getcwd(), "mock_solaar.txt")
    ]
    
    text = ""
    error_msg = None
    
    # Try finding and reading sample or mock files first (useful for development)
    for sample_path in sample_paths:
        if os.path.exists(sample_path):
            try:
                with open(sample_path, 'r') as f:
                    text = f.read()
                break
            except Exception as e:
                error_msg = f"Fehler beim Lesen der sample_output.txt ({sample_path}): {str(e)}"
                
    if not text and not error_msg:
        for mock_path in mock_paths:
            if os.path.exists(mock_path):
                try:
                    with open(mock_path, 'r') as f:
                        text = f.read()
                    break
                except Exception as e:
                    error_msg = f"Fehler beim Lesen der Mock-Datei ({mock_path}): {str(e)}"
            
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
