$basePath = "e:\Testing Gymkhana App\MemberShipModule"

$files = @()
$files += Get-ChildItem -Path $basePath -Filter "*.aspx" -File
$files += Get-ChildItem -Path "$basePath\Reports" -Filter "*.aspx" -File -ErrorAction SilentlyContinue

$gridCss = @"
        <style>
            /* Grid, Table & Structural Styles (Self-contained for server deployments) */
            .table-container { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; margin-bottom: 1rem; box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); }
            .table { width: 100%; border-collapse: collapse; font-size: 0.95rem; text-align: left; }
            .table th { background: #f8fafc; color: #334155; font-weight: 600; padding: 0.75rem 1rem; border-bottom: 2px solid #e2e8f0; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
            .table td { padding: 0.75rem 1rem; border-bottom: 1px solid #e2e8f0; color: #0f172a; vertical-align: middle; }
            .table tr:last-child td { border-bottom: none; }
            .empty-state { padding: 2rem; text-align: center; color: #94a3b8; background-color: #f8fafc; border: 1px dashed #e2e8f0; border-radius: 12px; display: flex; flex-direction: column; align-items: center; gap: 0.75rem; margin-top: 1rem; }
            .empty-state svg { color: #94a3b8; opacity: 0.6; margin-bottom: 0.5rem; }
            .table-input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid transparent; border-radius: 6px; background: transparent; font-size: 0.95rem; color: #0f172a; transition: all 0.2s ease; }
            .table-input:hover { background: #f1f5f9; border-color: #e2e8f0; }
            .table-input:focus { background: #ffffff; border-color: #3b82f6; box-shadow: 0 0 0 2px #dbeafe; outline: none; }
            .btn-sm.flex { display: inline-flex; align-items: center; justify-content: center; }
            .form-control { display: block; width: 100%; padding: 0.35rem 0.5rem; font-size: 0.9rem; font-weight: 400; line-height: 1.2; color: #0f172a; background-color: white; border: 1px solid #cbd5e1; border-radius: 6px; }
            .form-control:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); outline: none; }
        </style>
"@

$updated = 0
foreach ($file in $files) {
    if ($file.Name -match "Site.master") { continue }
    
    $content = [System.IO.File]::ReadAllText($file.FullName)
    
    # Check if we already injected these table classes
    if ($content.Contains(".table-container { background: #ffffff;") -or $content.Contains("Grid, Table & Structural Styles")) {
        continue
    }

    $regex = [regex]'(?i)(<asp:Content[^>]+ContentPlaceHolderID="HeadContent"[^>]*>)'
    $match = $regex.Match($content)
    
    if ($match.Success) {
        $insertionPoint = $match.Index + $match.Length
        $newContent = $content.Insert($insertionPoint, "`r`n$gridCss")
        [System.IO.File]::WriteAllText($file.FullName, $newContent)
        Write-Host "Updated Grid CSS for $($file.Name)"
        $updated++
    }
}

Write-Host "Injected Grid/Table styles into $updated files."
