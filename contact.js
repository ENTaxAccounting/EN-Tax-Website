// Form submission handler
document.getElementById('contactForm').addEventListener('submit', async function(e) {
    e.preventDefault();

    const btn = this.querySelector('.submit-btn');
    const originalText = btn.textContent;
    btn.textContent = 'Sending…';
    btn.disabled = true;

    try {
        const response = await fetch('https://formspree.io/f/xeergwwe', {
            method: 'POST',
            headers: { 'Accept': 'application/json' },
            body: new FormData(this)
        });

        if (response.ok) {
            this.innerHTML = '<div style="text-align:center;padding:40px 20px"><div style="font-size:48px;margin-bottom:20px">✅</div><h3 style="color:var(--primary-color);margin-bottom:15px">Message Sent!</h3><p style="font-size:18px;color:#6C757D">Thank you for reaching out. E&amp;N Tax &amp; Accounting will be in touch within 24–48 business hours.</p></div>';
        } else {
            throw new Error('Server error');
        }
    } catch (err) {
        btn.textContent = originalText;
        btn.disabled = false;
        const errorMsg = document.getElementById('form-error');
        if (errorMsg) errorMsg.style.display = 'block';
    }
});

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});
