/**
 * Global RFID Scanner Listener
 * Listens for keyboard input that mimics an RFID reader (fast typing + Enter).
 * Modern ES6+ Version
 */

(function () {
    let buffer = "";
    let lastKeyTime = Date.now();
    const SCAN_THRESHOLD_MS = 100; // Max ms between keystrokes to be considered a scan
    const MIN_LENGTH = 5; // Minimum length of an RFID tag

    document.addEventListener('keydown', (e) => {
        const currentTime = Date.now();

        // Ignore modifier keys
        if (e.ctrlKey || e.altKey || e.metaKey) return;

        // If "Enter" is pressed, check buffer
        if (e.key === "Enter") {
            if (buffer.length >= MIN_LENGTH) {
                // It's likely a scan!
                const activeEl = document.activeElement;
                handleScan(buffer, activeEl);
                buffer = ""; // Clear buffer

                // Prevent default form submission if focused on a non-input
                if (document.activeElement.tagName !== "TEXTAREA") {
                    e.preventDefault();
                }
            } else {
                buffer = "";
            }
            return;
        }

        // Calculate time since last key
        if ((currentTime - lastKeyTime) > SCAN_THRESHOLD_MS) {
            // Too slow, probably manual typing. Reset buffer.
            buffer = "";
        }

        // Add typical characters (alphanumeric)
        if (e.key.length === 1) {
            buffer += e.key;
        }

        lastKeyTime = currentTime;
    });

    async function handleScan(tagNumber, activeElement) {
        console.log("RFID Scanned:", tagNumber);

        // Show scanning indicator
        showToast("Scanning...", "info");

        try {
            const response = await fetch('RFIDLookup.asmx/GetMemberByTag', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ tagNumber: tagNumber })
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            const member = data.d;

            if (member && member.Found) {
                showToast(`Member Found: ${member.Name}`, "success");
                
                // Dynamically update the field where the RFID was scanned into
                if (activeElement && activeElement.tagName === 'INPUT') {
                    activeElement.value = member.MemberNo;
                    // Trigger change to notify any listeners (like AutoPostBack)
                    activeElement.dispatchEvent(new Event('change'));
                }
                
                fillFields(member, activeElement);
            } else {
                const errorMsg = (member && member.Message) ? member.Message : "Member not found";
                showToast(errorMsg, "error");
                if (member && member.Message && member.Message.includes("Server Exception")) {
                    alert(member.Message);
                }
                
                // Clear the invalid RFID tag string from the input
                if (activeElement && activeElement.tagName === 'INPUT') {
                    activeElement.value = '';
                    activeElement.dispatchEvent(new Event('change'));
                }
            }
        } catch (err) {
            console.error("Error parsing response:", err);
            showToast("Error processing scan", "error");
            alert("Error processing scan: " + err.message);
        }
    }

    function fillFields(member, activeElement) {
        // Heuristic mapping: Try to find common ID patterns on the page
        setValueIfExists('MainContent_txtMemberNo', member.MemberNo);
        setValueIfExists('txtMemberNo', member.MemberNo);

        setValueIfExists('MainContent_txtMemberName', member.Name);
        setValueIfExists('txtName', member.Name);
        setValueIfExists('MainContent_txtApplicantName', member.Name);

        setValueIfExists('MainContent_txtStatus', member.Status);

        setTextIfExists('MainContent_lblMemberName', member.Name);
        setTextIfExists('MainContent_lblStatus', member.Status);

        // Auto-trigger search button after RFID scan
        const searchBtn = document.getElementById('MainContent_btnSearch') || document.getElementById('btnSearch');
        if (searchBtn) {
            console.log('Auto-triggering search for Member No:', member.MemberNo);
            setTimeout(() => { searchBtn.click(); }, 300);
        } else if (activeElement && activeElement.tagName === 'INPUT') {
            // If no search button found but we scanned into an input, check if we can trigger postback logic
            if (activeElement.onchange) {
                activeElement.onchange();
            } else if (typeof __doPostBack !== 'undefined' && activeElement.id) {
                console.log('Auto-triggering postback for input:', activeElement.id);
                setTimeout(() => { __doPostBack(activeElement.name || activeElement.id, ''); }, 300);
            }
        }
    }

    function setValueIfExists(id, value) {
        const el = document.getElementById(id);
        if (el && (el.tagName === 'INPUT' || el.tagName === 'SELECT')) {
            el.value = value;
            // Trigger change event
            el.dispatchEvent(new Event('change'));
        }
    }

    function setTextIfExists(id, value) {
        const el = document.getElementById(id);
        if (el) {
            el.innerText = value;
        }
    }

    function showToast(msg, type) {
        const toast = document.createElement('div');
        toast.className = `rfid-toast ${type}`;
        toast.innerText = msg;
        document.body.appendChild(toast);

        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 3000);
    }

    // Inject styles for toast
    const style = document.createElement('style');
    style.textContent = `
        .rfid-toast {
            position: fixed;
            bottom: 20px;
            right: 20px;
            padding: 10px 20px;
            border-radius: 5px;
            color: white;
            z-index: 9999;
            font-family: sans-serif;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
            transition: opacity 0.3s;
        }
        .rfid-toast.info { background: #3b82f6; }
        .rfid-toast.success { background: #10b981; }
        .rfid-toast.error { background: #ef4444; }
    `;
    document.head.appendChild(style);
})();
