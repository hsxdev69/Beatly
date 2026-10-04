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

        # API: Stream resolver proxy (InnerTube & yt_dlp real stream extraction)
        if parsed.path == '/api/stream':
            qs = urllib.parse.parse_qs(parsed.query)
            vid = qs.get('id', [''])[0]
            query = qs.get('q', [''])[0]
            stream_url = None
            mime_type = 'audio/mp4'
            duration_sec = 240

            # Strategy 1: yt_dlp direct stream resolver
            try:
                import yt_dlp
                ydl_opts = {
                    'format': 'bestaudio[ext=m4a]/bestaudio/best',
                    'quiet': True,
                    'no_warnings': True,
                    'noplaylist': True,
                }
                with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                    info = None
                    if vid and len(vid) == 11 and ' ' not in vid:
                        try:
                            info = ydl.extract_info(f"https://www.youtube.com/watch?v={vid}", download=False)
                        except Exception:
                            info = None
                    if not info and (query or vid):
                        try:
                            info = ydl.extract_info(f"ytsearch1:{query or vid}", download=False)
                        except Exception:
                            info = None
                    if info:
                        entry = info['entries'][0] if 'entries' in info else info
                        resolved = entry.get('url')
                        if resolved:
                            stream_url = resolved
                            duration_sec = int(entry.get('duration', 240))
                            mime_type = 'audio/mp4' if entry.get('ext') == 'm4a' else 'audio/webm'
            except Exception as e:
                print(f"[StreamResolver] yt_dlp exception: {e}")

            # Strategy 2: Piped / Invidious fallback if yt_dlp didn't resolve
            if not stream_url and vid:
                for piped in ['https://pipedapi.kavin.rocks', 'https://api.piped.privacy.com.de', 'https://piped-api.lunar.icu']:
                    try:
                        req = urllib.request.Request(f"{piped}/streams/{vid}", headers={'User-Agent': 'Mozilla/5.0'})
                        with urllib.request.urlopen(req, timeout=4) as res:
                            data = json.loads(res.read().decode('utf-8'))
                        audio_streams = data.get('audioStreams', [])
                        if audio_streams:
                            stream_url = audio_streams[0].get('url')
                            mime_type = audio_streams[0].get('mimeType', 'audio/webm')
                            break
                    except Exception:
                        pass

            if stream_url:
                self._send_json({
                    'success': True,
                    'streamUrl': stream_url,
                    'mimeType': mime_type,
                    'bitrate': 160000,
                    'durationSeconds': duration_sec,
                })
            else:
                self._send_json({
                    'success': False,
                    'error': f'Failed to resolve stream for {vid or query}',
                    'streamUrl': '',
                })
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
