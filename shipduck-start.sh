#!/usr/bin/env bash
set -euo pipefail

cd /workspace/super-saas

# Load managed runtime env when available.
[ -f /workspace/.shipduck/runtime.env ] && source /workspace/.shipduck/runtime.env
[ -f /workspace/.shipduck/docker.env ] && source /workspace/.shipduck/docker.env

PORT="${PORT:-${PREVIEW_PORT:-7567}}"
HOST="0.0.0.0"

if command -v python3 >/dev/null 2>&1; then
  exec python3 -m http.server "$PORT" --bind "$HOST"
fi

if command -v python >/dev/null 2>&1; then
  exec python -m http.server "$PORT" --bind "$HOST"
fi

if command -v node >/dev/null 2>&1; then
  exec node -e "const http=require('http');const fs=require('fs');const path=require('path');const host='${HOST}';const port=Number(process.env.PORT||'${PORT}');http.createServer((req,res)=>{let p=decodeURIComponent((req.url||'/').split('?')[0]);if(p==='/' ) p='/index.html';const f=path.join(process.cwd(),p.replace(/^\\/+/,''));fs.readFile(f,(e,d)=>{if(e){res.statusCode=404;res.end('Not Found');return;}res.end(d);});}).listen(port,host,()=>console.log('listening on '+host+':'+port));"
fi

echo "No supported runtime found (python3/python/node)." >&2
exit 1
