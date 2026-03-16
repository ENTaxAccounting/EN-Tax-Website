// Hero carousel functionality
(function() {
    const bgImages = Array.from(document.querySelectorAll('.hero-bg-image'));
    const textItems = Array.from(document.querySelectorAll('.hero-text-item'));
    const total = bgImages.length;
    if (total === 0 || textItems.length === 0) return;

    let current = 0;

    function rotateHeroContent() {
        bgImages[current].classList.remove('active');
        textItems[current].classList.remove('active');
        current = (current + 1) % total;
        bgImages[current].classList.add('active');
        textItems[current].classList.add('active');
    }

    setInterval(rotateHeroContent, 8000);
})();

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
