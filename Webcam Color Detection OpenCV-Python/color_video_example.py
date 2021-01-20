# By James Samawi 11/1/2020
# Python code for Multiple Color Detection from a webcam
# Adapted from https://www.geeksforgeeks.org/multiple-color-detection-in-real-time-using-python-opencv/
import numpy as np
import cv2

# Capturing video through webcam 
webcam = cv2.VideoCapture(0)

if not webcam.isOpened():
    raise IOError("Cannot open webcam")

# Start a while loop 
while 1:
    # Reading the video from the webcam in image frames
    _, imageFrame = webcam.read()

    # Convert the imageFrame in BGR(RGB color space) to HSV(hue-saturation-value) color space
    hsvFrame = cv2.cvtColor(imageFrame, cv2.COLOR_BGR2HSV)

    # Used GPick Ubuntu program to choose HSV colors
    # Hue = color, Saturation = color + white, Value = color + black
    # OpenCV style HSV: H: 0-179, S: 0-255, V: 0-255
    # To match it with the standard HSV scale (0-360, 0-100, 0-100),
    # divide hue by 2, and for S/V you multiply by 2.55.
    # strategy for low-bound: 	H: value just before left-hand color transition
    #							S: halfway between 255 for decent saturation baseline
    #							V: low enough to detect dark colors, but not too low!
    # strategy for upper-bound: H: value just after right-hand color transition
    #							S: max at 255 for highest saturation
    #							V: max at 255 for highest value

    # Set range for red color and define mask
    red_lower = np.array([163, 127, 65], np.uint8)
    red_upper = np.array([180, 255, 255], np.uint8)
    red_mask = cv2.inRange(hsvFrame, red_lower, red_upper)

    # Set range for green color and define mask
    green_lower = np.array([40, 127, 62], np.uint8)
    green_upper = np.array([80, 255, 255], np.uint8)
    green_mask = cv2.inRange(hsvFrame, green_lower, green_upper)

    # Set range for blue color and define mask
    blue_lower = np.array([86, 127, 65], np.uint8)
    blue_upper = np.array([126, 255, 255], np.uint8)
    blue_mask = cv2.inRange(hsvFrame, blue_lower, blue_upper)

    # Morphological Transform, Dilation
    # Each color and bitwise_and operator between imageFrame and mask detects only that particular color
    kernel = np.ones((5, 5), "uint8")

    # For red color
    red_mask = cv2.dilate(red_mask, kernel)
    res_red = cv2.bitwise_and(imageFrame, imageFrame, mask=red_mask)

    # For green color
    green_mask = cv2.dilate(green_mask, kernel)
    res_green = cv2.bitwise_and(imageFrame, imageFrame, mask=green_mask)

    # For blue color
    blue_mask = cv2.dilate(blue_mask, kernel)
    res_blue = cv2.bitwise_and(imageFrame, imageFrame, mask=blue_mask)

    # Creating contour to track red color
    contours, hierarchy = cv2.findContours(red_mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    for pic, contour in enumerate(contours):
        area = cv2.contourArea(contour)
        if area > 300:
            x, y, w, h = cv2.boundingRect(contour)
            imageFrame = cv2.rectangle(imageFrame, (x, y), (x + w, y + h), (0, 0, 255), 2)
            cv2.putText(imageFrame, "Red Color", (x, y), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 0, 255))

        # Creating contour to track green color
    contours, hierarchy = cv2.findContours(green_mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    for pic, contour in enumerate(contours):
        area = cv2.contourArea(contour)
        if area > 300:
            x, y, w, h = cv2.boundingRect(contour)
            imageFrame = cv2.rectangle(imageFrame, (x, y), (x + w, y + h), (0, 255, 0), 2)
            cv2.putText(imageFrame, "Green Color", (x, y), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 0))

        # Creating contour to track blue color
    contours, hierarchy = cv2.findContours(blue_mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    for pic, contour in enumerate(contours):
        area = cv2.contourArea(contour)
        if area > 300:
            x, y, w, h = cv2.boundingRect(contour)
            imageFrame = cv2.rectangle(imageFrame, (x, y), (x + w, y + h), (255, 0, 0), 2)
            cv2.putText(imageFrame, "Blue Color", (x, y), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (255, 0, 0))

        # Program Termination
    cv2.imshow("Multiple Color Detection in Real-Time", imageFrame)
    if cv2.waitKey(10) & 0xFF == ord('q'):
        webcam.release()
        cv2.destroyAllWindows()
        break
