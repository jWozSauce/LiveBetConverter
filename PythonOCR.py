import time
import mss
import numpy as np
import cv2
from PIL import Image
import pytesseract
import requests

# ← paste your Apps Script Web app URL here:
WEB_APP_URL = "https://script.google.com/macros/s/AKfycbx10nlWEl3OcaE1hpMVvz5tYBtGQN_jp3ejB3BvvJvI5bS5fY8jTOSE99IimStAIfbZ7A/exec"

def select_region():
    """Grab full screen once and let the user draw an ROI."""
    with mss.mss() as sct:
        mon = sct.monitors[1]
        img = np.array(sct.grab(mon))[:, :, :3]
    roi = cv2.selectROI("Select region (ENTER to confirm)", img, showCrosshair=True)
    cv2.destroyAllWindows()
    x, y, w, h = roi
    return {"left": x, "top": y, "width": w, "height": h}

def main():
    print("1) Draw a box around the area you want to OCR.")
    region = select_region()
    print("Selected region:", region)

    with mss.mss() as sct:
        try:
            while True:
                shot  = sct.grab(region)
                frame = np.array(shot)[:, :, :3]

                # OCR the region
                pil = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
                text = pytesseract.image_to_string(pil).strip()

                # POST to your public sheet
                resp = requests.post(WEB_APP_URL, json={"text": text})
                if resp.status_code != 200:
                    print("Error writing to sheet:", resp.text)

                # show live feed
                cv2.imshow("Live OCR (press Q to quit)", frame)
                if cv2.waitKey(1000) & 0xFF in (ord('q'), ord('Q')):
                    break
        finally:
            cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
