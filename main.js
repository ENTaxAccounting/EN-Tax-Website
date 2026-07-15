function setMenuOpen(open, returnFocus = false) {
    const navLinks = document.getElementById('navLinks');
    const toggle = document.querySelector('.menu-toggle');
    if (!navLinks || !toggle) return;

    navLinks.classList.toggle('active', open);
    toggle.setAttribute('aria-expanded', String(open));

    if (!open) {
        if (returnFocus) toggle.focus();
    }
}

function toggleMenu() {
    const navLinks = document.getElementById('navLinks');
    if (!navLinks) return;
    setMenuOpen(!navLinks.classList.contains('active'));
}

document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.getElementById('navLinks');

    if (menuToggle) menuToggle.addEventListener('click', toggleMenu);

    if (navLinks) {
        navLinks.addEventListener('click', event => {
            if (event.target.closest('a') && window.innerWidth <= 1024) {
                setMenuOpen(false);
            }
        });
    }

    document.addEventListener('keydown', event => {
        if (event.key === 'Escape' && navLinks?.classList.contains('active')) {
            setMenuOpen(false, true);
        }
    });

    window.addEventListener('resize', () => {
        if (window.innerWidth > 1024) setMenuOpen(false);
    });

});

function reveal() {
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    document.querySelectorAll('.reveal').forEach(element => {
        const shouldReveal = reducedMotion
            || element.getBoundingClientRect().top < window.innerHeight - 150;
        if (shouldReveal) element.classList.add('active');
    });
}

let scrollTicking = false;
window.addEventListener('scroll', function() {
    if (scrollTicking) return;

    requestAnimationFrame(function() {
        reveal();
        const header = document.querySelector('header');
        if (header) {
            header.style.boxShadow = window.scrollY > 50
                ? '0 4px 20px rgba(0,0,0,0.1)'
                : '0 2px 8px rgba(0,0,0,0.08)';
        }
        scrollTicking = false;
    });
    scrollTicking = true;
});

reveal();
