import http.server
import socketserver
import urllib.request
import urllib.parse
import json
import os
import sys

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(__file__), 'build', 'web')

class EchoMusicHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        
        # API: Search songs (iTunes / YouTube proxy)
        if parsed.path == '/api/search':
            qs = urllib.parse.parse_qs(parsed.query)
            query = qs.get('q', [''])[0]
            if not query:
                self._send_json([])
                return
            
            try:
                encoded = urllib.parse.quote(query)
                url = f"https://itunes.apple.com/search?term={encoded}&entity=song&limit=25"
                req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
                with urllib.request.urlopen(req, timeout=8) as res:
                    data = json.loads(res.read().decode('utf-8'))
                
                results = []
                for item in data.get('results', []):
                    preview = item.get('previewUrl')
                    if preview:
                        art = item.get('artworkUrl100', '')
                        if art:
                            art = art.replace('100x100bb', '600x600bb')
                        results.append({
                            'id': str(item.get('trackId')),
                            'title': item.get('trackName', 'Unknown'),
                            'artist': item.get('artistName', 'Unknown'),
                            'album': item.get('collectionName', item.get('trackName', '')),
                            'coverUrl': art or 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600',
                            'audioUrl': preview,
                            'durationSeconds': int(item.get('trackTimeMillis', 180000) / 1000),
                        })
                self._send_json(results)
            except Exception as e:
                self._send_json({'error': str(e)})
            return

        # API: Lyrics proxy (LRCLIB)
        if parsed.path == '/api/lyrics':
            qs = urllib.parse.parse_qs(parsed.query)
            track = qs.get('track', [''])[0]
            artist = qs.get('artist', [''])[0]
            try:
                encoded = urllib.parse.quote(f"{artist} {track}".strip())
                url = f"https://lrclib.net/api/search?q={encoded}"
                req = urllib.request.Request(url, headers={'User-Agent': 'EchoMusic/1.0'})
                with urllib.request.urlopen(req, timeout=6) as res:
                    data = json.loads(res.read().decode('utf-8'))
                
                synced = ""
                plain = ""
                if isinstance(data, list) and len(data) > 0:
                    for entry in data:
                        if entry.get('syncedLyrics'):
                            synced = entry['syncedLyrics']
                            break
                        if not plain and entry.get('plainLyrics'):
                            plain = entry['plainLyrics']
                
                self._send_json({'syncedLyrics': synced, 'plainLyrics': plain})
            except Exception as e:
                self._send_json({'error': str(e), 'syncedLyrics': '', 'plainLyrics': ''})
            return

        # API: Stream resolver proxy
        if parsed.path == '/api/stream':
            qs = urllib.parse.parse_qs(parsed.query)
            vid = qs.get('id', [''])[0]
            stream_url = None
            for piped in ['https://pipedapi.kavin.rocks', 'https://api.piped.privacy.com.de', 'https://piped-api.lunar.icu']:
                try:
                    req = urllib.request.Request(f"{piped}/streams/{vid}", headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req, timeout=4) as res:
                        data = json.loads(res.read().decode('utf-8'))
                    audio_streams = data.get('audioStreams', [])
                    if audio_streams:
                        stream_url = audio_streams[0].get('url')
                        break
                except Exception:
                    pass
            self._send_json({'streamUrl': stream_url or '', 'mimeType': 'audio/webm', 'bitrate': 160000, 'durationSeconds': 240})
            return

        return super().do_GET()

    def _send_json(self, data):
        payload = json.dumps(data).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

if __name__ == '__main__':
    class ReusableTCPServer(socketserver.TCPServer):
        allow_reuse_address = True

    with ReusableTCPServer(('0.0.0.0', PORT), EchoMusicHandler) as httpd:
        print(f"Echo Music Backend & Web Server running on port {PORT}")
        httpd.serve_forever()
