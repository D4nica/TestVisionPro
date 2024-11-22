import requests
import json
from flask import Flask, request, jsonify,send_file
import os

app = Flask(__name__)

#receive from VisionOS
@app.route('/', methods=['POST'])
def handle_post_request():
    data = request.data
    print("Request headers: ", request.headers)
    print("Received data: ", data, type(data), len(data))
    if not data:
        return jsonify({'error': 'No data received'}), 400
    try:
        received_text = data.decode('utf-8')
        print("Received text:", received_text)
    except UnicodeDecodeError:
        return jsonify({'error': 'Failed to decode data'}), 400
    return jsonify({'message': 'Data received successfully'})

#send to VisionOS
@app.route('/text', methods=['GET'])
def get_data():  
    posts = [
        {"userId": 1, "id": 1, "title": "Post 1", "body": "This is the body of post 1"},
    ]
    return jsonify(posts)

@app.route('/image', methods=['GET'])
def get_image():
    image_path = '/Users/sunniva/Desktop/rainbowlake@2x.jpg'
    if not os.path.exists(image_path):
        return "Image not found", 404
    return send_file(image_path, mimetype='image/jpeg')

if __name__ == '__main__':
    app.run(host='192.168.0.142',debug=True, port=8080)


