#!/usr/bin/env python3
import http.server
import socketserver
import os
import json
import urllib.parse

class WeatherHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/weather-key':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            api_key = os.environ.get('OPENWEATHER_API_KEY', '')
            response = {'apiKey': api_key}
            self.wfile.write(json.dumps(response).encode())
        else:
            super().do_GET()

if __name__ == "__main__":
    PORT = 5000
    with socketserver.TCPServer(("0.0.0.0", PORT), WeatherHandler) as httpd:
        print(f"Serving at http://0.0.0.0:{PORT}")
        httpd.serve_forever()