# Render.com Configuration Guide

## Environment Variables Required:

1. **RAILS_ENV**: production
2. **SECRET_KEY_BASE**: (your secret key)
3. **MONGODB_URI**: (your MongoDB Atlas connection string)
4. **PORT**: 10000 (default Render port - auto-set by Render)

## Build Command:
```
./bin/render-build.sh
```

## Start Command (choose one):
```
./bin/render-start.sh
```
OR
```
bundle exec puma -C config/puma.rb
```

## Key Fixes Applied:

1. **Puma Configuration**: Always uses TCP binding in production (no Unix sockets)
2. **Memory Optimization**: Reduced workers (1) and threads (1-3) for free tier
3. **Directory Creation**: Ensures tmp/ and log/ directories exist
4. **Node.js Version**: Updated to 20.18.0 (maintained version)
5. **Port Conflict**: Added start script that kills old processes
6. **Build Process**: Simplified to avoid webpack/babel compilation issues

## Latest Status:
- ✅ Build successful on Render
- ✅ Puma using TCP on port 10000
- 🔧 Fixed memory usage for free tier
- 🚀 Ready for deployment!

## Troubleshooting:
If you get "Address already in use", the start script should handle this automatically by killing old processes first.
