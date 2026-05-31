import os
import requests

FILE_PATH = "system_id.txt"
SERVER = "http://192.168.137.212:8088"


def get_system_id():
    if os.path.exists(FILE_PATH):
        with open(FILE_PATH, "r") as f:
            system_id = f.read().strip()
            if system_id:
                return system_id

    return register_system()


def register_system():
    url = SERVER + "/api/systems/register"

    data = {
        "name": "Fruit Sorter Pi",
        "description": "AI Conveyor",
        "location": "Da Nang"
    }

    res = requests.post(url, params=data)

    if res.status_code == 200:
        system_id = res.json()

        with open(FILE_PATH, "w") as f:
            f.write(system_id)

        print("[SYSTEM] Registered:", system_id)
        return system_id

    print("[SYSTEM] Register failed")
    return None
