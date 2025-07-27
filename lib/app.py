import cv2
import pytesseract
from matplotlib import pyplot as plt
import numpy as np
from flask import Flask, request, jsonify
import os
import threading
import re
import sys
import shutil


########################################################################################################################################Scheduling

def detect_and_merge_columns_4(image_path):
    image = cv2.imread(image_path)

    if image is None:
        print("خطأ: لم يتمكن من تحميل الصورة. تأكد من المسار.")
        return
    
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    _, thresh = cv2.threshold(blurred, 128, 255, cv2.THRESH_BINARY_INV)

    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (17, 2))  # تعديل حجم القناع لتحسين الكشف
    morph = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

    dilated = cv2.dilate(morph, kernel, iterations=3)

    contours, _ = cv2.findContours(dilated, cv2.RETR_TREE ,cv2.CHAIN_APPROX_SIMPLE)
    rectangles = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        rectangles.append((x, y, x + w, y + h))  # حفظ الإحداثيات
    rectangles.sort(key=lambda rect: rect[0])  # فرز المستطيلات أفقيًا

    # دمج المستطيلات لكل عمود
    merged_rectangles = []
    for rect in rectangles:
        x1, y1, x2, y2 = rect
        if not merged_rectangles:
            merged_rectangles.append(rect)
        else:
            # إذا كان المستطيل الحالي قريبًا أفقيًا من المستطيل الأخير، يتم دمجه
            last_x1, last_y1, last_x2, last_y2 = merged_rectangles[-1]
            if abs(x1 - last_x1) < 50:  # تعديل العتبة حسب الحاجة
                merged_rectangles[-1] = (
                    min(last_x1, x1),
                    min(last_y1, y1),
                    max(last_x2, x2),
                    max(last_y2, y2),
                )
            else:
                merged_rectangles.append(rect)
    merged_rectangles_2=[]
    cc=0
    for i in merged_rectangles:
        cc+=1
        if cc!=1:
            merged_rectangles_2.append(i)
    merged_rectangles_3=[]
    index=[]
    for idx1, rect in enumerate(merged_rectangles_2):  
        x1, y1, x2, y2 = rect
        for idx2, j in enumerate(merged_rectangles_2): 
            x11, y11, x22, y22 = j
            margin = 10
            if abs(x22 - x2) <= margin and rect != j and y1>y11 :
                index.append(idx1)
    for idx1, rect in enumerate(merged_rectangles_2):
        if idx1 in index:
            continue
        else:
            merged_rectangles_3.append(rect)
    Coordinates=[]
    for idx1, rect in enumerate(merged_rectangles_3):
        x1, y1, x2, y2 = rect
        if (idx1==1 or idx1==2) and len(merged_rectangles_3)==8:
            Coordinates.append(rect)
        elif (idx1==2 or idx1==3) and len(merged_rectangles_3)>8:
            Coordinates.append(rect)
        cv2.rectangle(image, (x1-5, y1-10), (x2+5, y2+5), (0, 255, 0), 2)
    image_read = cv2.imread(image_path)
    x1,y1,x2,y2=Coordinates[0]
    image1=image_read[y1-10:y2+5,x1-5:x2+5]
    x1,y1,x2,y2=Coordinates[1]
    image2=image_read[y1-10:y2+5,x1-5:x2+5]
    output_path = r"temp\output_cut_new.png"
    output_path_cut_1 = r"temp\output_cut_new_1.png"
    output_path_cut_2 = r"temp\output_cut_new_2.png"
    cv2.imwrite(output_path, image)
    cv2.imwrite(output_path_cut_1, image1)
    cv2.imwrite(output_path_cut_2, image2)

##########################################################################################################################################



##################################################TO DISPLAY IMAGE
def display(im_path):
    dpi = 80
    im_data = plt.imread(im_path)

    height, width  = im_data.shape[:2]
    
    # What size does the figure need to be in inches to fit the image?
    figsize = width / float(dpi), height / float(dpi)

    # Create a figure of the right size with one axes that takes up the full figure
    fig = plt.figure(figsize=figsize)
    ax = fig.add_axes([0, 0, 1, 1])

    # Hide spines, ticks, etc.
    ax.axis('off')

    # Display the image.
    ax.imshow(im_data, cmap='gray')

    plt.show()
##################################################

##################################################TO CONVERT IMAGE 
def grayscale(image):
    return cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
##################################################

###################################################TO THIN FONT
def thin_font(image):
    image = cv2.bitwise_not(image)
    kernel = np.ones((2,2),np.uint8)
    image = cv2.erode(image, kernel, iterations=1)
    image = cv2.bitwise_not(image)
    return (image)
#################################################


################################################TO THICK FONT
def thick_font(image):
    image = cv2.bitwise_not(image)
    kernel = np.ones((2,2),np.uint8)
    image = cv2.dilate(image, kernel, iterations=1)
    image = cv2.bitwise_not(image)
    return (image)
################################################


###############################################TO REMOVE BORDERS
def remove_borders(image):
    contours, heiarchy = cv2.findContours(image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cntsSorted = sorted(contours, key=lambda x:cv2.contourArea(x))
    cnt = cntsSorted[-1]
    x, y, w, h = cv2.boundingRect(cnt)
    crop = image[y:y+h, x:x+w]
    return (crop)
################################################



app = Flask(__name__)  # يجب استخدام __name بدلاً من name
d_data = set()

@app.route('/my-python-function', methods=['POST'])
def my_python_function():
    data = request.get_json()
    print("البيانات المستلمة:", data)  # طباعة البيانات المستلمة

    # تحديث d_data بالعناصر من البيانات المستلمة
    d_data.update(data.get('numbers', []))
    response = list(d_data)

    return jsonify({'numbers': 'python, I received this: ' + str(response)})


@app.route('/shutdown', methods=['POST'])
def shutdown():
    print("Shutting down the server via Windows command...")
    ####################################################
    for i in d_data:
        image_file = str(i)
    img = cv2.imread(image_file)
    gray_image = grayscale(img)
    cv2.imwrite("temp/gray.jpg", gray_image)

    thresh, im_bw = cv2.threshold(gray_image, 215, 255, cv2.THRESH_BINARY)
    cv2.imwrite("temp/bw_image.jpg", im_bw)

    eroded_image = thin_font(im_bw)
    cv2.imwrite("temp/eroded_image.jpg", eroded_image)


    dilated_image = thick_font(im_bw)
    cv2.imwrite("temp/dilated_image.jpg", dilated_image)

    no_borders = remove_borders(im_bw)
    cv2.imwrite("temp/no_borders.jpg", no_borders)

    color = [255, 255, 255]
    top, bottom, left, right = [150]*4

    image_with_border = cv2.copyMakeBorder(no_borders, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color)
    cv2.imwrite("temp/image_with_border.jpg",image_with_border)

    image=cv2.imread(r'temp/image_with_border.jpg')
    base_image = image.copy()
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    cv2.imwrite("temp/index_gray.png", gray)
    blur = cv2.GaussianBlur(gray, (7,7), 0)
    cv2.imwrite("temp/index_blur.png", blur)
    thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]
    cv2.imwrite("temp/index_thresh.png", thresh)
    kernal = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 13))
    cv2.imwrite("temp/index_kernal.png", kernal)
    dilate = cv2.dilate(thresh, kernal, iterations=1)
    cv2.imwrite("temp/index_dilate.png", dilate)
    cnts = cv2.findContours(dilate, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = cnts[0] if len(cnts) == 2 else cnts[1]
    xx=0
    yy=0
    hh=0
    ww=0

    for c in cnts:
        x, y, w, h = cv2.boundingRect(c)
        if h > 200 and w > 20:
            roi = image[y:y+h, x:x+h]
            cv2.rectangle(image, (x, y), (x+w, y+h), (36, 255, 12), 2)
            xx=x
            yy=y
            hh=h
            ww=w
    cv2.imwrite("temp/index_bbox_new.png", image)


    img=image[yy:(yy+hh),xx:(xx+ww)]
    cv2.imwrite("temp/output_cut.png", img)
    (hieght,width)=img.shape[0:2]

    detect_and_merge_columns_4("temp/output_cut.png")

    im2=cv2.imread(r"temp/output_cut_new_1.png")
    ocr_result=pytesseract.image_to_string(im2)
    print(ocr_result)
    pattern = r"\b([01]?\d|2[0-3]):[0-5]\d\s*-\s*([01]?\d|2[0-3]):[0-5]\d\b"
    if ocr_result!='' and re.match(pattern, ocr_result):
        result=ocr_result.split('\n')
        result_of_time=[]
        for i in result:
            if i=='':
                continue
            i=i.replace('.','')
            result_of_time.append(i)




        im3=cv2.imread(r"temp/output_cut_new_2.png")

        # استخراج النص باستخدام تيسراكت
        custom_config = r'--oem 3 --psm 6'
        text = pytesseract.image_to_string(im3, config=custom_config)

        reslut_day=text.split('\n')
        reslut_day_new=[]
        for i in reslut_day:
            if i!="":
                if i=='8' or i=='$s' or i=='s' or i==']' or i=='&' or i=='Ss' or i=='5':
                    reslut_day_new.append('S')
                    continue
                elif i=='su' or i=='Su':
                    reslut_day_new.append('Su')
                    continue
                elif i=='tu':
                    reslut_day_new.append('Tu')
                    continue
                elif i=='m':
                    reslut_day_new.append('M')
                    continue
                elif i=='w' or i=='Ww':
                    reslut_day_new.append('W')
                    continue
                reslut_day_new.append(i)
        for i in range(len(result_of_time)):
            pattern=r"^([01]?[0-9]|2[0-3]):([0-5][0-9]) - ([01]?[0-9]|2[0-3]):([0-5][0-9])$"
            if re.match(pattern,result_of_time[i]):
                result_of_time[i]=result_of_time[i]
            else:
                for j in result_of_time[i]:
                    if j=='-':
                        result_of_time[i]+=' - '
                        continue
                    elif j==' ':
                        continue
                    result_of_time[i]+=j

        result_day_and_time=[]
        for i in range(len(result_of_time)):
            result_day_and_time.append([reslut_day_new[i],result_of_time[i]])
        result_start_and_end=[]
        print(result_day_and_time)
        def get_min_start_max_end(schedules):
            days = {}
            for day, time_range in schedules:
                start_time, end_time = time_range.split(' - ')
                start_hour = int(start_time.split(':')[0])
                end_hour = int(end_time.split(':')[0])

                # التأكد من أن ساعة النهاية لا تتجاوز الساعة 16

                # تصحيح الخطأ: التأكد من أن ساعة النهاية أكبر من ساعة البداية
                if start_hour > end_hour:
                    start_hour, end_hour = end_hour, start_hour

                if day not in days:
                    days[day] = (start_hour, end_hour)
                else:
                    current_start, current_end = days[day]
                    if end_hour>16:
                        end_hour=16
                    if current_end>16:
                        current_end=16
                    # تحديث ساعة البداية كأصغر ساعة وساعة النهاية كأكبر ساعة
                    days[day] = (min(current_start, start_hour), max(current_end, end_hour))

            return days


        # عرض النتائج
        result_start_and_end = get_min_start_max_end(result_day_and_time)
        print(result_start_and_end)
        #######################################delet temp
        folder_path = r"C:\Users\VISION\Desktop\AMA WITH PHP WITH PY v10\lib\temp"
        # حذف المجلد إذا كان موجودًا
        if os.path.exists(folder_path):
            shutil.rmtree(folder_path)  # حذف المجلد بكافة محتوياته

        # إعادة إنشاء المجلد
        os.makedirs(folder_path)

        ##########################################
        correct_result_start_and_end={}
        pattern = r"^(?:\w+:\(\d+,\s*\d+\),?\s*)+$"
        f=False
        for i in result_start_and_end:
            text = i+':'+str(result_start_and_end[i])
            #print(text)
            match = re.match(pattern, text)
            if match:
                f=True
            else:
                f=False
        if f==True:
            correct_result_start_and_end=result_start_and_end
        else:
            correct_result_start_and_end.update({'res':'inter correct image'})

        #print(correct_result_start_and_end)
        ###################################################
        # الحصول على معرف العملية (PID) الخاص بالسيرفر الحالي
        
        response=jsonify({'res':str(correct_result_start_and_end)})
        timer = threading.Timer(2.0, shutdown_server)
        timer.start()
        return response
    else:
        response=jsonify({'res': 'python, I received this: ' + str('inter correct image')})
        timer = threading.Timer(2.0, shutdown_server)
        timer.start()
        return response
def shutdown_server():
    #pid = os.getpid()
    #os.system(f"taskkill /F /PID {pid}")
    python = sys.executable
    os.execv(python, ['python'] + sys.argv)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=True)