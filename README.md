# Multi-Channel FFPlayout Solution

A Docker-based multi-channel playout system using ffplayout for 24/7 broadcasting, configured to push streams directly to your existing media server.

## System Requirements

### Minimum Requirements (per channel)
- **CPU**: 4 dedicated threads minimum
- **RAM**: 3GB minimum for 720p output
- **Storage**: Depends on media library size (recommend 100GB+ for each channel)
- **Network**: Stable internet connection for streaming to your media server

### Recommended Requirements (3 channels)
- **CPU**: 8-12 cores (Intel Xeon or AMD EPYC recommended)
- **RAM**: 16-32GB
- **Storage**: SSD with 500GB+ for media storage
- **Network**: 1Gbps network interface
- **OS**: Linux (Ubuntu 22.04 LTS recommended) or Windows with WSL2

### Software Requirements
- Docker Engine 20.10+
- Docker Compose 2.0+
- FFmpeg v5.0+ (included in Docker image)
- For dynamic text overlay: FFmpeg with libzmq support
- External media server with RTMP publishing point support

## Architecture

This solution uses:
- **FFPlayout**: Rust and ffmpeg based playout engine
- **Docker**: Containerized deployment for easy management
- **Your Media Server**: External RTMP server for stream distribution

### Channel Configuration
- **Channel 1**: Web UI on port 8787
- **Channel 2**: Web UI on port 8788
- **Channel 3**: Web UI on port 8789

## Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd webplayout
```

### 2. Create Directory Structure
```bash
mkdir -p config/channel1 config/channel2 config/channel3
mkdir -p media/channel1 media/channel1/filler
mkdir -p media/channel2 media/channel2/filler
mkdir -p media/channel3 media/channel3/filler
mkdir -p playlists/channel1 playlists/channel2 playlists/channel3
mkdir -p logs/channel1 logs/channel2 logs/channel3
mkdir -p public
```

### 3. Configure Media Server Publishing Points
Edit the configuration files in `config/channelX/ffplayout.yml`:
- Replace `YOUR_MEDIA_SERVER` with your actual media server address
- Replace `publishing_point_channelX` with your actual publishing point names
- Adjust output parameters (bitrate, resolution, etc.) if needed
- Set correct RPC ports (7070, 7071, 7072)
- Configure storage paths
- Set timezone if needed

Example output configuration:
```yaml
output:
  mode: "stream"
  output_param: "-c:v libx264 -crf 23 -x264-params keyint=50:min-keyint=25:scenecut=-1 -maxrate 1300k -bufsize 2600k -preset faster -tune zerolatency -profile:v Main -level 3.1 -c:a aac -ar 44100 -b:a 128k -flags +cgop -flags +global_header -f flv rtmp://media-server.example.com/live/channel1"
```

### 4. Add Media Files
Place your video files in the respective media directories:
```bash
# Channel 1
cp /path/to/your/videos/* media/channel1/
cp /path/to/filler/* media/channel1/filler/

# Repeat for other channels
```

### 5. Create Playlists
Create JSON playlists in the playlists directories. See `playlist_example.json` for format.

### 6. Start the System
```bash
docker-compose up -d
```

### 7. Initialize FFPlayout
For each channel, initialize with admin user:
```bash
docker exec -it ffplayout-channel1 ffplayout -i
docker exec -it ffplayout-channel2 ffplayout -i
docker exec -it ffplayout-channel3 ffplayout -i
```

Default credentials:
- **Username**: admin
- **Password**: admin

**Important**: Change default passwords after first login!

## Accessing the System

### Web Interface
- Channel 1: http://localhost:8787
- Channel 2: http://localhost:8788
- Channel 3: http://localhost:8789

### Stream Output
Streams are pushed directly to your configured media server publishing points. Access the streams through your media server's distribution endpoints.

## Management

### View Logs
```bash
# All channels
docker-compose logs -f

# Specific channel
docker logs -f ffplayout-channel1
```

### Stop System
```bash
docker-compose down
```

### Restart a Channel
```bash
docker restart ffplayout-channel1
```

### Update FFPlayout
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Configuration Options

### Output Formats
Each channel can output to:
- **Stream**: RTMP, SRT, RTP (pushes to your media server)
- **Desktop**: Local playback
- **HLS**: HTTP Live Streaming (if supported by your media server)
- **Null**: For debugging

### Video Processing
- Resolution: Configurable (default 1280x720)
- FPS: Configurable (default 30)
- Bitrate: Configurable (default 1300k)
- Codec: H.264 (libx264)
- Audio: AAC

### Features
- Dynamic playlist management
- Filler content for gaps
- Logo overlay
- Text overlay (requires libzmq)
- Live ingest
- Multiple audio tracks
- Custom filters

## Troubleshooting

### Container won't start
```bash
docker-compose logs ffplayout-channel1
```

### No stream output
- Verify media server is accessible
- Check output URL in ffplayout.yml matches your publishing point
- Verify network connectivity to media server
- Check media server authentication/credentials

### High CPU usage
- Reduce video resolution
- Lower bitrate
- Use stream copy mode if source matches output

### Storage issues
- Ensure sufficient disk space
- Check file permissions
- Verify media file formats

## Scaling

### Adding More Channels
1. Add new service in docker-compose.yml
2. Create config/media/playlists directories
3. Configure unique web UI port and RPC port
4. Set unique publishing point in ffplayout.yml

### Load Balancing
For high availability:
- Deploy multiple instances
- Use load balancer (HAProxy, Nginx)
- Implement failover mechanisms

## Security Recommendations

1. **Change default passwords** immediately
2. **Use reverse proxy** with SSL (Traefik, Nginx)
3. **Restrict network access** with firewall rules
4. **Regular updates** of Docker images
5. **Monitor logs** for suspicious activity
6. **Backup configurations** regularly

## Support

- FFPlayout Documentation: https://github.com/ffplayout/ffplayout
- FFPlayout Website: https://ffplayout.github.io
- Issues: Report via GitHub Issues

## License

This configuration is provided as-is. FFPlayout is licensed under its own license.
