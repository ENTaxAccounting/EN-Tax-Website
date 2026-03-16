// Hero carousel functionality
let currentSlide = 0;
const totalSlides = 5;
const slideInterval = 8000; // 8 seconds

function rotateHeroContent() {
    // Hide current slide
    document.querySelectorAll('.hero-bg-image')[currentSlide].classList.remove('active');
    document.querySelectorAll('.hero-text-item')[currentSlide].classList.remove('active');

    // Move to next slide
    currentSlide = (currentSlide + 1) % totalSlides;

    // Show next slide
    document.querySelectorAll('.hero-bg-image')[currentSlide].classList.add('active');
    document.querySelectorAll('.hero-text-item')[currentSlide].classList.add('active');
}

// Start the carousel — pauses on hover
let carouselTimer = setInterval(rotateHeroContent, slideInterval);
const heroSection = document.querySelector('.hero');
heroSection.addEventListener('mouseenter', () => clearInterval(carouselTimer));
heroSection.addEventListener('mouseleave', () => {
    carouselTimer = setInterval(rotateHeroContent, slideInterval);
});

// Tap-to-reveal for client cards on touch devices
document.querySelectorAll('.client-card').forEach(card => {
    let touchMoved = false;
    card.addEventListener('touchstart', () => { touchMoved = false; }, { passive: true });
    card.addEventListener('touchmove', () => { touchMoved = true; }, { passive: true });
    card.addEventListener('touchend', (e) => {
        if (touchMoved) return;
        e.preventDefault(); // prevents ghost click firing after touchend
        const isTapped = card.classList.contains('tapped');
        document.querySelectorAll('.client-card').forEach(c => c.classList.remove('tapped'));
        if (!isTapped) card.classList.add('tapped');
    }, { passive: false });
});
