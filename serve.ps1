$port = if ($env:PORT) { [int]$env:PORT } else { 8090 }
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
$listener.Start()
Write-Host "Server running on http://localhost:$port"
$root = $PSScriptRoot

while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = [System.IO.StreamReader]::new($stream)
    $requestLine = $reader.ReadLine()
    # Read remaining headers
    while ($true) {
        $line = $reader.ReadLine()
        if ([string]::IsNullOrEmpty($line)) { break }
    }

    $path = ($requestLine -split ' ')[1]
    if ($path -eq '/') { $path = '/WebAudio_Prototype.html' }
    $filePath = Join-Path $root ($path.TrimStart('/').Replace('/', '\'))

    $writer = [System.IO.StreamWriter]::new($stream)
    if (Test-Path $filePath) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $ext = [System.IO.Path]::GetExtension($filePath)
        $ct = switch ($ext) {
            '.html' { 'text/html; charset=utf-8' }
            '.css'  { 'text/css' }
            '.js'   { 'application/javascript' }
            '.json' { 'application/json' }
            '.png'  { 'image/png' }
            '.svg'  { 'image/svg+xml' }
            default { 'application/octet-stream' }
        }
        $writer.Write("HTTP/1.1 200 OK`r`nContent-Type: $ct`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n`r`n")
        $writer.Flush()
        $stream.Write($bytes, 0, $bytes.Length)
    } else {
        $writer.Write("HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n")
        $writer.Flush()
    }
    $stream.Close()
    $client.Close()
}
