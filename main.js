// Mobile Menu Toggle
function toggleMenu() {
    const navLinks = document.getElementById('navLinks');
    const toggle = document.querySelector('.menu-toggle');
    navLinks.classList.toggle('active');
    toggle.setAttribute('aria-expanded', navLinks.classList.contains('active'));

    // Reset dropdown states when closing menu
    if (!navLinks.classList.contains('active')) {
        const dropdowns = navLinks.querySelectorAll('.dropdown');
        dropdowns.forEach(dropdown => {
            dropdown.classList.remove('active');
        });
    }
}

// Mobile dropdown toggle
document.addEventListener('DOMContentLoaded', function() {
    // Wire hamburger button
    const menuToggle = document.querySelector('.menu-toggle');
    if (menuToggle) {
        menuToggle.addEventListener('click', toggleMenu);
    }

    const dropdownTriggers = document.querySelectorAll('.dropdown > a');

    dropdownTriggers.forEach(trigger => {
        trigger.addEventListener('click', function(e) {
            if (window.innerWidth <= 1024) {
                e.preventDefault();
                const dropdown = this.parentElement;
                dropdown.classList.toggle('active');

                // Close other dropdowns
                const siblings = dropdown.parentElement.querySelectorAll('.dropdown');
                siblings.forEach(sibling => {
                    if (sibling !== dropdown) {
                        sibling.classList.remove('active');
                    }
                });
            }
        });
    });
});

// Scroll Reveal Animation
function reveal() {
    const reveals = document.querySelectorAll('.reveal');

    reveals.forEach(element => {
        const windowHeight = window.innerHeight;
        const elementTop = element.getBoundingClientRect().top;
        const elementVisible = 150;

        if (elementTop < windowHeight - elementVisible) {
            element.classList.add('active');
        }
    });
}

// Throttled scroll handler (combines reveal + header shadow)
let scrollTicking = false;
window.addEventListener('scroll', function() {
    if (!scrollTicking) {
        requestAnimationFrame(function() {
            reveal();
            const header = document.querySelector('header');
            header.style.boxShadow = window.scrollY > 50
                ? '0 4px 20px rgba(0,0,0,0.1)'
                : '0 2px 8px rgba(0,0,0,0.08)';
            scrollTicking = false;
        });
        scrollTicking = true;
    }
});
reveal(); // Initial check
