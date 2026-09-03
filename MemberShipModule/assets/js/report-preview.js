function openPrintPreview() {
    // Get the page title
    var pageTitle = document.title;

    // Get the content to print (the .card element usually contains the report)
    // We clone it to not mess up the original page
    var reportContent = document.querySelector('.card').cloneNode(true);

    // Remove the "Export" and "Print" buttons from the clone
    var buttons = reportContent.querySelectorAll('.btn, button, .no-print');
    buttons.forEach(function (btn) {
        btn.remove();
    });

    // Make report header visible in preview
    var reportHeader = reportContent.querySelector('.report-header');
    if (reportHeader) {
        reportHeader.style.display = 'block';
        reportHeader.style.textAlign = 'center';
        reportHeader.style.marginBottom = '20px';
    }

    // Prepare the window content
    var printWindow = window.open('', '_blank');

    var htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
            <title>${pageTitle}</title>
            <link href="../assets/css/styles.css?v=8.2" rel="stylesheet" />
            <link href="../assets/css/print.css?v=1.0" rel="stylesheet" />
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
            <style>
                body {
                    background-color: #525659; /* Acrobat dark grey background */
                    padding: 40px 0;
                    margin: 0;
                    display: flex;
                    justify-content: center;
                    min-height: 100vh;
                }
                .preview-container {
                    background: white;
                    width: 210mm; /* A4 Width */
                    min-height: 297mm; /* A4 Height */
                    padding: 20mm;
                    box-shadow: 0 0 10px rgba(0,0,0,0.5);
                    box-sizing: border-box;
                    margin: 0 auto;
                }
                @media print {
                    body {
                        background: none;
                        padding: 0;
                        margin: 0;
                        display: block;
                    }
                    .preview-container {
                        width: 100%;
                        height: auto;
                        padding: 0;
                        box-shadow: none;
                        margin: 0;
                    }
                }
            </style>
        </head>
        <body>
            <div class="preview-container">
                ${reportContent.innerHTML}
            </div>
            <script>
                // Auto print after a short delay to allow styles to load
                // window.onload = function() { setTimeout(function(){ window.print(); }, 500); }
            </script>
        </body>
        </html>
    `;

    printWindow.document.write(htmlContent);
    printWindow.document.close();
}
