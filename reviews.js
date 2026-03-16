function escapeHtml(str) {
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

async function loadReviews() {
    const container = document.getElementById('reviews-container');
    try {
        const res = await fetch('reviews-data.json');
        if (!res.ok) throw new Error('not found');
        const data = await res.json();

        if (!data.reviews || data.reviews.length === 0) {
            container.innerHTML = '<p style="text-align:center;color:#6C757D;font-size:18px;padding:40px 0;">Reviews coming soon.</p>';
            return;
        }

        const cards = data.reviews
            .filter(r => r.text)
            .map(r => {
                const stars = '★'.repeat(r.rating || 5);
                const words = r.author_name.trim().split(/\s+/);
                const initials = (words[0][0] + (words.length > 1 ? words[words.length - 1][0] : '')).toUpperCase();
                const dateStr = r.time ? new Date(r.time * 1000).toLocaleDateString('en-US', { month: 'long', year: 'numeric' }) : '';
                return `
                <div class="review-card reveal">
                    <div class="review-stars">${stars}</div>
                    <p class="review-text">"${escapeHtml(r.text)}"</p>
                    <div class="review-author">
                        <div class="author-avatar">${escapeHtml(initials)}</div>
                        <div>
                            <div class="author-name">${escapeHtml(r.author_name)}</div>
                            ${dateStr ? `<div class="author-type">${dateStr}</div>` : ''}
                        </div>
                    </div>
                    <div class="review-source">via Google</div>
                </div>`;
            }).join('');

        container.innerHTML = `<div class="review-cards-grid">${cards}</div>`;
        reveal();
    } catch (e) {
        console.error('Could not load reviews:', e);
    }
}

loadReviews();
