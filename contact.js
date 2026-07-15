// Form submission handler
document.getElementById('contactForm').addEventListener('submit', async function(e) {
    e.preventDefault();

    const btn = this.querySelector('.submit-btn');
    const errorMsg = document.getElementById('form-error');
    const originalText = btn.textContent;
    if (errorMsg) errorMsg.classList.remove('is-visible');
    btn.textContent = 'Sending…';
    btn.disabled = true;

    try {
        const response = await fetch('https://formspree.io/f/xeergwwe', {
            method: 'POST',
            headers: { 'Accept': 'application/json' },
            body: new FormData(this)
        });

        if (response.ok) {
            this.innerHTML = '<div class="form-success" role="status" tabindex="-1"><div class="form-success-icon" aria-hidden="true">✅</div><h3>Message Sent!</h3><p>Thank you for reaching out. E&amp;N Tax &amp; Accounting will be in touch within 24–48 business hours.</p></div>';
            this.querySelector('.form-success').focus();
        } else {
            throw new Error('Server error');
        }
    } catch (err) {
        btn.textContent = originalText;
        btn.disabled = false;
        if (errorMsg) errorMsg.classList.add('is-visible');
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
