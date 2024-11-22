#https://www.geeksforgeeks.org/create-a-sideshow-application-in-python/
from openai import OpenAI 
import tkinter as tk 
from tkinter import *
from PIL import Image 
from PIL import ImageTk 
import json
import threading
import time
import MatchAudioToOCR
import SharedServerData

# ##Change below too
lec_number = '11'
folder_name = 'Lecture11'
number_of_slide = 13 

##Change below too
# lec_number = '14'
# folder_name = 'Lecture14'
# number_of_slide = 14 

# #Change below too
# lec_number = '15'
# folder_name = 'Lecture15_new'
# number_of_slide = 18


# # adjust window 
root=tk.Tk() 
root.attributes('-fullscreen', True)  # Set the window to full screen

# loading the images 
folder_path =  '/Users/sunniva/Desktop/ARDHH-DEV/Python/'+folder_name+'/' # "/Users/sunniva/Desktop/VisionProRecording/visionpro-slide.png" 
slide_name_list = ['lec'+lec_number+'-'+str(i) for i in range(0,number_of_slide+1,1)]

slide_all = []
for slide_name in slide_name_list:
    path = folder_path + slide_name + '.png'
    img = Image.open(path)
    img = img.resize((int(2667*0.5665), int(1500*0.5665)))
    img_tk = ImageTk.PhotoImage(img, size=img.size) 
    slide_all.append(img_tk)

x = -1
label = tk.Label(root,background='black')
label.pack(expand = True)
label.place(x=0, y=-17.5, width=root.winfo_screenwidth(), height=root.winfo_screenheight())

def move(): #Recursion mode
    global x, slide_number
    if x >= len(slide_all):
        x = 0
    label.config(image=slide_all[x])
    label.image = slide_all[x]  # Keep a reference to avoid garbage collection
    x += 1
    root.after(1000, move)

def move_next(event=None): #Button mode
    global x, slide_number
    x = (x + 1) % len(slide_all)
    label.config(image=slide_all[x])
    label.image = slide_all[x] 

def move_previous(event=None):#Button mode
    global x, slide_number
    x = (x - 1) % len(slide_all)
    label.config(image=slide_all[x])
    label.image = slide_all[x]


def show_slide(event=None):
    old_post = SharedServerData.get_post()
    old_post_dict = old_post[0]      
    new_post = [
    {
        "showImmersiveSpace": True,
        "isRecording": old_post_dict["isRecording"],
        "ocrKeyword": old_post_dict["ocrKeyword"],
        "slideNumber": old_post_dict["slideNumber"],
        "captionHighlight": old_post_dict["captionHighlight"],
        "summary": old_post_dict["summary"],
        "slideX": old_post_dict["slideX"],
        "slideY": old_post_dict["slideY"],
        "slideW": old_post_dict["slideW"],
        "slideH": old_post_dict["slideH"],
        }
    ]
    SharedServerData.update_posts(new_post) 
    print("show slide")

def hide_slide(event=None):
    old_post = SharedServerData.get_post()
    old_post_dict = old_post[0]
    new_post = [
    {
        "showImmersiveSpace": False,
        "isRecording": old_post_dict["isRecording"],
        "ocrKeyword": old_post_dict["ocrKeyword"],
        "slideNumber": old_post_dict["slideNumber"],
        "captionHighlight": old_post_dict["captionHighlight"],
        "summary": old_post_dict["summary"],
        "slideX": old_post_dict["slideX"],
        "slideY": old_post_dict["slideY"],
        "slideW": old_post_dict["slideW"],
        "slideH": old_post_dict["slideH"],
        }
    ]
    SharedServerData.update_posts(new_post) 
    print("hide slide")


def start_transcription(event=None):
    old_post = SharedServerData.get_post()
    old_post_dict = old_post[0]      
    new_post = [
    {
        "showImmersiveSpace": old_post_dict['showImmersiveSpace'],
        "isRecording": True,
        "ocrKeyword": old_post_dict["ocrKeyword"],
        "slideNumber": old_post_dict["slideNumber"],
        "captionHighlight": old_post_dict["captionHighlight"],
        "summary": old_post_dict["summary"],
        "slideX": old_post_dict["slideX"],
        "slideY": old_post_dict["slideY"],
        "slideW": old_post_dict["slideW"],
        "slideH": old_post_dict["slideH"],
        }
    ]
    SharedServerData.update_posts(new_post) 
    print("start_transcription")
    
def end_trasncription(event=None):
    old_post = SharedServerData.get_post()
    old_post_dict = old_post[0]
    new_post = [
    {
        "showImmersiveSpace": old_post_dict['showImmersiveSpace'],
        "isRecording": False,
        "ocrKeyword": old_post_dict["ocrKeyword"],
        "slideNumber": old_post_dict["slideNumber"],
        "captionHighlight": old_post_dict["captionHighlight"],
        "summary": old_post_dict["summary"],
        "slideX": old_post_dict["slideX"],
        "slideY": old_post_dict["slideY"],
        "slideW": old_post_dict["slideW"],
        "slideH": old_post_dict["slideH"],
        }
    ]
    SharedServerData.update_posts(new_post) 
    print("end_transcription")

def remove_numeric_values(input_dict, topN, topSim = 0.7):
    cleaned_dict = {}
    for key, value in input_dict.items():
        cleaned_dict[key] = {}
        for inner_key, inner_value in value.items():
            # with topN
            cleaned_list = [inner_key] + [item[0] for item in inner_value[:topN]]
            # with topSim > 0.7
            for word_list in inner_value:
                word, sim = word_list
                if sim > 0.7:
                    cleaned_list.append(word)
            cleaned_dict[key][inner_key] = cleaned_list
    return cleaned_dict

def presentation_updates(client, lec_number, slide_number, result_processed, potential_caption_dict, transcript_simulator= None, interval=0.25):
    global x
    slide_number = "lec"+str(lec_number)+"-"+str(x) #slide number
    start_time = time.time()
    if slide_number != "lec15--1" and slide_number != "lec15-0" and slide_number != "lec11--1" and slide_number != "lec11-0":
        for _ in range(1):
            try:
                MatchAudioToOCR.update_match_call(client, slide_number, result_processed, potential_caption_dict,transcript_simulator)
                print("Match took ", time.time() - start_time)
            except:
                continue
    threading.Timer(interval, presentation_updates, args=[client, lec_number, slide_number,result_processed, potential_caption_dict, transcript_simulator, interval]).start()

def summary_updates(client, lec_number, slide_number, result_processed, prev_ocr_keyword, interval=0.25):
    global x
    slide_number = "lec"+str(lec_number)+"-"+str(x) #slide number
    print()
    print(slide_number)
    if slide_number != "lec15--1" and slide_number != "lec15-0" and slide_number != "lec11--1" and slide_number != "lec11-0":
        for _ in range(1):
            try:
                start_time = time.time()
                prev_ocr_keyword = MatchAudioToOCR.update_summary_call(client, slide_number, result_processed,prev_ocr_keyword)
                print("Summary took ", time.time() - start_time)
            except:
                continue
    threading.Timer(interval, summary_updates, args=[client, lec_number, slide_number, result_processed, prev_ocr_keyword, interval]).start()

if __name__ == "__main__":
    
    # #Change above too
    lec_number = '11'
    folder_name = 'Lecture11' 
    number_of_slide = 13 
    
    ##Change above too
    # lec_number = '14'
    # folder_name = 'Lecture14'
    # number_of_slide = 14 

    # #Change above too
    # lec_number = '15'
    # folder_name = 'Lecture15_new'
    # number_of_slide = 18
    
    
    #Load Data
    # client = OpenAI(api_key = 'sk-proj-fa6wLv3jF1SdiNSNHvcpT3BlbkFJdDwWUtWFE9Xfd7WxOTmQ') -- Sunniva's API
    
    # Bear Lab's API
    client = OpenAI(api_key = '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')
    
    folder_path =  '/Users/sunniva/Desktop/ARDHH-DEV/Python/'+folder_name+'/'
    slide_name_list = ['lec'+lec_number+'-'+str(i) for i in range(1,number_of_slide+1,1)]
    with open(folder_path+'lec'+lec_number+'-keywords.json', 'r') as json_file:
        keyword_dict = json.load(json_file)
    with open(folder_path+'lec'+lec_number+'_ocr_keyword.json', 'r') as json_file:
        keyword_ocr_dict = json.load(json_file) 
    with open(folder_path+'lec'+lec_number+'_potential_caption.json', 'r') as json_file:
        potential_caption_dict = json.load(json_file)    
    
    #Remove semantic scores and keep only the top 3
    potential_caption_dict = remove_numeric_values(potential_caption_dict, 3)
    print("potential_caption_dict",potential_caption_dict)
    #Initialize Transcript History by summarizing from keyword
    init_historical_transcript = " " 
    json_file = open("transcript_history.json", "w")
    json.dump(init_historical_transcript, json_file)
    json_file.close()

    #Initialize Server Post
    init_post = [
    {
        "showImmersiveSpace": True,
        "isRecording": True, # when update match call is called, it will become true
        "ocrKeyword": "-1",
        "slideNumber": "lec"+lec_number+"-1",
        "captionHighlight": "-1",
        "summary": "[summary]", #Example: "A robust approach to identifying and correcting real word spelling errors, improving the accuracy of text processing systems.",
        "slideX": 0,
        "slideY": 0,
        "slideW": 0,
        "slideH": 0,
        }
    ]
    json_file = open("server_posts.json", "w")
    json.dump(init_post, json_file)
    json_file.close()    

    # presentation_updates(client, keyword_ocr_dict, potential_caption_dict, transcript_simulator=None, interval=0.1)
    init_slide_number = 'lec'+lec_number+'-0'
    init_prev_ocr_keyword = '-1'

    presentation_updates_thread = threading.Thread(target=presentation_updates, args=[client, lec_number, init_slide_number, keyword_ocr_dict, potential_caption_dict])
    presentation_updates_thread.daemon = True
    presentation_updates_thread.start()
    
    summary_updates_thread = threading.Thread(target=summary_updates, args=[client,lec_number, init_slide_number, keyword_ocr_dict, init_prev_ocr_keyword])
    summary_updates_thread.daemon = True
    summary_updates_thread.start()

    # PRESENTATION-Bind key events to the functions
    root.bind('<Down>', move_next)
    root.bind('<Up>', move_previous)
    root.bind('<s>', start_transcription)
    root.bind('<e>', end_trasncription)
    root.bind('<i>', show_slide)
    root.bind('<o>', hide_slide)

    move_next()
    root.mainloop()
    