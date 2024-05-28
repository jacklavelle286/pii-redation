function generateCaptcha() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let captcha = '';
    for (let i = 0; i < 6; i++) {
        captcha += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    document.getElementById('captcha').textContent = captcha;
}

document.getElementById('upload-form').addEventListener('submit', function(event) {
    event.preventDefault();
    
    var fileInput = document.getElementById('file-input');
    var emailInput = document.getElementById('email-input');
    var captchaInput = document.getElementById('captcha-input');
    var captcha = document.getElementById('captcha').textContent;
    
    var file = fileInput.files[0];
    var email = emailInput.value;
    var captchaValue = captchaInput.value;

    if (file && email && captchaValue === captcha) {
        var formData = new FormData();
        formData.append('file', file);
        formData.append('email', email);

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'YOUR_API_ENDPOINT', true);

        xhr.onload = function () {
            if (xhr.status === 200) {
                document.getElementById('upload-status').textContent = 'File uploaded successfully!';
            } else {
                document.getElementById('upload-status').textContent = 'File upload failed. Please try again.';
            }
        };

        xhr.send(formData);
    } else {
        document.getElementById('upload-status').textContent = 'Please provide a file, an email address, and enter the correct CAPTCHA.';
    }
});

document.getElementById('refresh-captcha').addEventListener('click', function() {
    generateCaptcha();
});

// Generate CAPTCHA on page load
generateCaptcha();
