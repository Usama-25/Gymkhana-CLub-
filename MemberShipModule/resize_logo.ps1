$path = "e:\App\MemberShipModule\assets\images\logo_new.png"
Add-Type -AssemblyName System.Drawing

[System.Drawing.Image]$img = $null
try {
    $img = [System.Drawing.Image]::FromFile($path)
    $w = $img.Width
    $h = $img.Height
    
    # Target height to be half of width, but not more than current height
    $targetH = [Math]::Min([int]($w / 2), $h)
    
    if ($targetH -lt $h) {
        $startY = [int](($h - $targetH) / 2)
        
        $rect = New-Object System.Drawing.Rectangle(0, $startY, $w, $targetH)
        $bmp = New-Object System.Drawing.Bitmap($w, $targetH)
        
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $w, $targetH)), $rect, [System.Drawing.GraphicsUnit]::Pixel)
        
        $img.Dispose()
        $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
        
        $g.Dispose()
        $bmp.Dispose()
        Write-Host "Image successfully cropped to $w x $targetH"
    } else {
        $img.Dispose()
        Write-Host "Image is already wider than it is tall, no crop needed."
    }
} catch {
    if ($img -ne $null) { $img.Dispose() }
    Write-Host "Error processing image: $_"
}
