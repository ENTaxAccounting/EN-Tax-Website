(function() {
    const bgImages = Array.from(document.querySelectorAll('.hero-bg-image'));
    const textItems = Array.from(document.querySelectorAll('.hero-text-item'));
    const toggle = document.querySelector('.hero-toggle');
    if (bgImages.length === 0 || bgImages.length !== textItems.length || !toggle) return;

    const reducedMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    const smallViewportQuery = window.matchMedia('(max-width: 768px)');
    const rotationInterval = 8000;
    const preloadLead = 1500;
    const preloadPromises = new Map([[0, Promise.resolve(true)]]);
    let current = 0;
    let isPaused = reducedMotionQuery.matches;
    let preloadTimer;
    let rotationTimer;

    function preloadSlide(index) {
        if (preloadPromises.has(index)) return preloadPromises.get(index);

        const slide = bgImages[index];
        const source = smallViewportQuery.matches
            ? slide.dataset.imageSmall
            : slide.dataset.imageLarge;
        const promise = new Promise(resolve => {
            const image = new Image();
            image.addEventListener('load', () => {
                slide.classList.add('is-loaded');
                resolve(true);
            }, { once: true });
            image.addEventListener('error', () => resolve(false), { once: true });
            image.src = source;
        });

        preloadPromises.set(index, promise);
        return promise;
    }

    function rotateTo(index) {
        bgImages[current].classList.remove('active');
        textItems[current].classList.remove('active');
        textItems[current].setAttribute('aria-hidden', 'true');

        current = index;
        bgImages[current].classList.add('active');
        textItems[current].classList.add('active');
        textItems[current].setAttribute('aria-hidden', 'false');
    }

    function clearSchedule() {
        window.clearTimeout(preloadTimer);
        window.clearTimeout(rotationTimer);
    }

    function scheduleRotation() {
        clearSchedule();
        if (isPaused || document.hidden) return;

        const next = (current + 1) % bgImages.length;
        let nextReady;
        preloadTimer = window.setTimeout(() => {
            nextReady = preloadSlide(next);
        }, rotationInterval - preloadLead);

        rotationTimer = window.setTimeout(async () => {
            const loaded = await (nextReady || preloadSlide(next));
            if (!isPaused && !document.hidden && loaded) rotateTo(next);
            scheduleRotation();
        }, rotationInterval);
    }

    function updateToggle() {
        toggle.setAttribute('aria-pressed', String(isPaused));
        toggle.textContent = isPaused ? 'Play slideshow' : 'Pause slideshow';
    }

    function setPaused(paused) {
        isPaused = paused;
        updateToggle();
        if (isPaused) clearSchedule();
        else scheduleRotation();
    }

    toggle.addEventListener('click', () => setPaused(!isPaused));
    document.addEventListener('visibilitychange', scheduleRotation);
    reducedMotionQuery.addEventListener('change', event => {
        if (event.matches) setPaused(true);
    });

    updateToggle();
    scheduleRotation();
})();

(function() {
    const cards = document.querySelectorAll('.client-card');
    if (cards.length === 0) return;

    if (!('IntersectionObserver' in window)) {
        cards.forEach(card => card.classList.add('is-image-loaded'));
        return;
    }

    const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (!entry.isIntersecting) return;
            entry.target.classList.add('is-image-loaded');
            observer.unobserve(entry.target);
        });
    }, { rootMargin: '300px 0px' });

    cards.forEach(card => observer.observe(card));
})();

document.querySelectorAll('.client-card').forEach(card => {
    let touchMoved = false;
    card.addEventListener('touchstart', () => { touchMoved = false; }, { passive: true });
    card.addEventListener('touchmove', () => { touchMoved = true; }, { passive: true });
    card.addEventListener('touchend', event => {
        if (touchMoved) return;
        event.preventDefault();
        const isTapped = card.classList.contains('tapped');
        document.querySelectorAll('.client-card').forEach(item => item.classList.remove('tapped'));
        if (!isTapped) card.classList.add('tapped');
    }, { passive: false });
});
