---
layout: page
---

# Email Communications

{% email_start %}
<div class="email-header">
    <div><strong>To:</strong> recipient@example.com</div>
    <div><strong>CC:</strong> cc@example.com</div>
    <div><strong>Subject:</strong> Email Subject Here</div>
</div>
<div class="email-body">
    {{ "Hello, This is the **HTML** body of the email. You can include any HTML content here. Best regards, Your Name" | markdownify }}
</div>
<div class="email-footer">
    <p>Forwarded message:</p>
    <p>---------- Forwarded message ----------<br>
    From: <strong>originalsender@example.com</strong><br>
    Date: <span id="email-date"></span><br>
    Subject: Original Email Subject<br>
    To: <strong>recipient@example.com</strong><br>
    CC: <strong>cc@example.com</strong></p>
    <p>{{ "Original email content goes here..." | markdownify }}</p>
</div>
{% email_end 2 %}