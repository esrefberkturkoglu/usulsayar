const http = require('http');
const fs = require('fs');
const path = require('path');
const port = process.env.PORT || 8090;
const root = __dirname;
const mime = { '.html':'text/html;charset=utf-8', '.css':'text/css', '.js':'application/javascript', '.json':'application/json', '.png':'image/png', '.svg':'image/svg+xml' };
http.createServer((req, res) => {
  let p = req.url === '/' ? '/USULSAYAR.html' : req.url.split('?')[0];
  let fp = path.join(root, p);
  if (!fs.existsSync(fp)) { res.writeHead(404); return res.end(); }
  const ext = path.extname(fp);
  res.writeHead(200, {'Content-Type': mime[ext]||'application/octet-stream'});
  fs.createReadStream(fp).pipe(res);
}).listen(port, () => console.log(`Server running on http://localhost:${port}`));
