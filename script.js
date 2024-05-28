document.getElementById('upload-form').addEventListener('submit', function(event) {
    event.preventDefault();
    
    var fileInput = document.getElementById('file-input');
    var emailInput = document.getElementById('email-input');
    var file = fileInput.files[0];
    var email = emailInput.value;
    
    if (file && email) {
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
        document.getElementById('upload-status').textContent = 'Please provide both a file and an email address.';
    }
});
