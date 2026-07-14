const securityHeaders = {
    'Cache-Control': 'no-store, max-age=0',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' https://www.googletagmanager.com https://www.google-analytics.com; style-src 'self'; img-src 'self' data: https:; connect-src 'self' https://www.google-analytics.com https://analytics.google.com https://formspree.io; frame-ancestors 'none'; form-action 'self' https://formspree.io;",
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-Robots-Tag': 'noindex'
};

export async function onRequest(context) {
    const errorPageUrl = new URL('/404.html', context.request.url);
    const errorPage = await context.env.ASSETS.fetch(errorPageUrl);
    const headers = new Headers(errorPage.headers);

    for (const [name, value] of Object.entries(securityHeaders)) {
        headers.set(name, value);
    }

    return new Response(context.request.method === 'HEAD' ? null : errorPage.body, {
        status: 404,
        statusText: 'Not Found',
        headers
    });
}
