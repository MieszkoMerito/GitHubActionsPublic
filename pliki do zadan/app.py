from http.server import BaseHTTPRequestHandler, HTTPServer

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"<h1>Witaj Chmuro! Obraz utworzony przez GHA v1.</h1>")

print("Uruchamianie serwera na porcie 8080...")
HTTPServer(('', 8080), SimpleHandler).serve_forever()