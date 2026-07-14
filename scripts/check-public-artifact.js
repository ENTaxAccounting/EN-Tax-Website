const fs = require('fs');
const http = require('http');
const path = require('path');
const { URL } = require('url');

const publicOrigin = 'https://www.entaxaccounting.com';
const generatedPlatformFiles = ['_routes.json'];
const privatePlatformFiles = new Set(['_headers', ...generatedPlatformFiles]);
const textExtensions = new Set(['.css', '.html', '.js', '.json', '.txt', '.xml', '']);
const publicPages = [
    'index.html',
    'services.html',
    'resources.html',
    'reviews.html',
    'contact.html',
    '404.html'
];
const privateTestPaths = [
    '/_headers',
    '/AGENTS.md',
    '/production-roadmap.md',
    '/owner-work-packages.md',
    '/fetch-reviews.js',
    '/auth.js',
    '/.github/workflows/fetch-reviews.yml',
    '/.gitignore',
    '/public-files.json',
    '/scripts/build-public.js',
    '/images/backgrounds/shop.jpg',
    '/images/high-rez-original/lady-liberty.jpeg',
    '/does-not-exist-wpd1a'
];

function repositoryPatternToRoute(pattern) {
    if (pattern.endsWith('/**')) return `/${pattern.slice(0, -3)}/*`;
    return `/${pattern}`;
}

function loadManifest(projectRoot) {
    const manifestPath = path.join(projectRoot, 'public-files.json');
    const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

    if (
        !Array.isArray(manifest.publicFiles)
        || !Array.isArray(manifest.deploymentSources)
        || !Array.isArray(manifest.repositoryOnly)
    ) {
        throw new Error('public-files.json must define publicFiles, deploymentSources, and repositoryOnly arrays');
    }

    if (new Set(manifest.publicFiles).size !== manifest.publicFiles.length) {
        throw new Error('public-files.json contains duplicate public files');
    }

    const overlaps = manifest.publicFiles.filter(relativePath => (
        matchesRepositoryOnly(relativePath, manifest.repositoryOnly)
    ));
    if (overlaps.length > 0) {
        throw new Error(`Files cannot be both public and repository-only: ${overlaps.join(', ')}`);
    }

    manifest.publicFiles.sort();
    manifest.deploymentSources.sort();
    manifest.blockedRoutes = manifest.repositoryOnly.map(repositoryPatternToRoute).sort();

    if (manifest.blockedRoutes.length > 100) {
        throw new Error('Cloudflare Pages allows at most 100 Function include/exclude rules');
    }
    if (new Set(manifest.blockedRoutes).size !== manifest.blockedRoutes.length) {
        throw new Error('Repository-only paths generate duplicate Cloudflare Function routes');
    }

    return manifest;
}

function walkFiles(root, relativeDirectory = '') {
    const directory = path.join(root, relativeDirectory);
    const files = [];

    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
        const relativePath = path.posix.join(relativeDirectory, entry.name);
        if (entry.isDirectory()) {
            files.push(...walkFiles(root, relativePath));
        } else if (entry.isFile()) {
            files.push(relativePath);
        }
    }

    return files.sort();
}

function matchesRepositoryOnly(relativePath, patterns) {
    if (path.posix.basename(relativePath) === '.DS_Store') return true;

    return patterns.some(pattern => {
        if (pattern.endsWith('/**')) {
            const prefix = pattern.slice(0, -3);
            return relativePath === prefix || relativePath.startsWith(`${prefix}/`);
        }
        return relativePath === pattern;
    });
}

function verifySourceClassification(projectRoot, manifest) {
    const ignoredDirectories = new Set(['.git', 'dist']);
    const sourceFiles = [];

    function visit(relativeDirectory = '') {
        const directory = path.join(projectRoot, relativeDirectory);
        for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
            const relativePath = path.posix.join(relativeDirectory, entry.name);
            if (entry.isDirectory()) {
                if (!ignoredDirectories.has(relativePath)) visit(relativePath);
            } else if (entry.isFile()) {
                sourceFiles.push(relativePath);
            }
        }
    }

    visit();
    const publicSet = new Set(manifest.publicFiles);
    const unclassified = sourceFiles.filter(relativePath => (
        !publicSet.has(relativePath)
        && !matchesRepositoryOnly(relativePath, manifest.deploymentSources)
        && !matchesRepositoryOnly(relativePath, manifest.repositoryOnly)
    ));

    if (unclassified.length > 0) {
        throw new Error(`Unclassified repository files:\n${unclassified.join('\n')}`);
    }
}

function normalizeReference(reference, sourceFile) {
    const trimmed = reference.trim();
    if (!trimmed || trimmed.startsWith('#')) return null;
    if (/^(?:data:|mailto:|tel:|javascript:|\/\/)/i.test(trimmed)) return null;

    let localReference = trimmed;
    if (/^https?:\/\//i.test(localReference)) {
        if (!localReference.startsWith(publicOrigin)) return null;
        localReference = localReference.slice(publicOrigin.length) || '/';
    }

    localReference = localReference.split('#')[0].split('?')[0];
    if (localReference === '/') return 'index.html';

    const decoded = decodeURIComponent(localReference);
    if (decoded.startsWith('/')) return decoded.slice(1);
    return path.posix.normalize(path.posix.join(path.posix.dirname(sourceFile), decoded));
}

function collectReferences(relativePath, content) {
    const references = [];
    const extension = path.extname(relativePath);
    let match;

    if (extension === '.html') {
        const attributePattern = /\b(?:href|src)=["']([^"']+)["']/gi;
        while ((match = attributePattern.exec(content))) references.push(match[1]);

        const publicUrlPattern = /https:\/\/www\.entaxaccounting\.com\/[^"'<\s]*/g;
        while ((match = publicUrlPattern.exec(content))) references.push(match[0]);
    }

    if (extension === '.css') {
        const cssUrlPattern = /url\(["']?([^"')]+)["']?\)/gi;
        while ((match = cssUrlPattern.exec(content))) references.push(match[1]);
    }

    if (extension === '.js') {
        const fetchPattern = /fetch\(["']([^"']+)["']/g;
        while ((match = fetchPattern.exec(content))) references.push(match[1]);
    }

    if (extension === '.xml') {
        const locationPattern = /<loc>([^<]+)<\/loc>/g;
        while ((match = locationPattern.exec(content))) references.push(match[1]);
    }

    return references;
}

function verifyTextContent(outputRoot, artifactFiles) {
    const artifactSet = new Set(artifactFiles);
    const internalPatterns = [
        /DO NOT PUBLISH/i,
        /INTERNAL ONLY/i,
        /PRIVATE NOTE/i,
        /\b(?:TODO|FIXME|HACK)\b/,
        /\.github\//,
        /AGENTS\.md/,
        /production-roadmap\.md/
    ];
    const credentialPatterns = [
        /-----BEGIN [A-Z ]*PRIVATE KEY-----/,
        /\bAKIA[0-9A-Z]{16}\b/,
        /\bgh[pousr]_[A-Za-z0-9]{20,}\b/,
        /\b(?:api[_-]?key|client[_-]?secret|password|passwd|access[_-]?token)\s*[:=]\s*["'][^"']{8,}["']/i
    ];

    for (const relativePath of artifactFiles) {
        if (generatedPlatformFiles.includes(relativePath)) continue;

        const extension = path.extname(relativePath);
        if (!textExtensions.has(extension)) continue;

        const content = fs.readFileSync(path.join(outputRoot, relativePath), 'utf8');
        for (const pattern of [...internalPatterns, ...credentialPatterns]) {
            if (pattern.test(content)) {
                throw new Error(`Forbidden internal or credential pattern in ${relativePath}: ${pattern}`);
            }
        }

        if (extension === '.html') {
            const comments = [...content.matchAll(/<!--[\s\S]*?-->/g)].map(match => match[0]);
            const commentedMarkup = comments.find(comment => /<\s*\/?\s*[a-z][^>]*>/i.test(comment));
            if (commentedMarkup) {
                throw new Error(`Commented-out markup remains in ${relativePath}`);
            }
        }

        for (const reference of collectReferences(relativePath, content)) {
            const normalized = normalizeReference(reference, relativePath);
            if (!normalized) continue;
            if (!artifactSet.has(normalized)) {
                throw new Error(`Broken local reference in ${relativePath}: ${reference}`);
            }
        }
    }
}

function verifyRequiredBehavior(outputRoot) {
    const headers = fs.readFileSync(path.join(outputRoot, '_headers'), 'utf8');
    const contactHtml = fs.readFileSync(path.join(outputRoot, 'contact.html'), 'utf8');
    const contactJs = fs.readFileSync(path.join(outputRoot, 'contact.js'), 'utf8');
    const routes = JSON.parse(fs.readFileSync(path.join(outputRoot, '_routes.json'), 'utf8'));

    if (!headers.includes('Content-Security-Policy:')) {
        throw new Error('_headers is missing the Content-Security-Policy');
    }
    if (headers.includes("'unsafe-inline'")) {
        throw new Error('CSP must not allow unsafe-inline');
    }
    if (!headers.includes('https://formspree.io')) {
        throw new Error('CSP must preserve Formspree access');
    }
    if (!contactHtml.includes('id="contactForm"') || !contactJs.includes('https://formspree.io/f/')) {
        throw new Error('Formspree contact-form wiring is incomplete');
    }
    if (routes.version !== 1 || !Array.isArray(routes.include) || !Array.isArray(routes.exclude)) {
        throw new Error('_routes.json is not a valid Cloudflare Pages routing configuration');
    }
    if (routes.exclude.length !== 0) {
        throw new Error('Repository-only route protection must not define exclusions');
    }
}

function contentType(relativePath) {
    const extension = path.extname(relativePath);
    if (extension === '.html') return 'text/html; charset=utf-8';
    if (extension === '.css') return 'text/css; charset=utf-8';
    if (extension === '.js') return 'text/javascript; charset=utf-8';
    if (extension === '.json') return 'application/json; charset=utf-8';
    if (extension === '.xml') return 'application/xml; charset=utf-8';
    if (extension === '.txt') return 'text/plain; charset=utf-8';
    return 'application/octet-stream';
}

function createArtifactServer(outputRoot) {
    return http.createServer((request, response) => {
        const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
        const relativePath = pathname === '/' ? 'index.html' : pathname.slice(1);
        const candidatePath = path.resolve(outputRoot, relativePath);
        const isPrivatePlatformFile = privatePlatformFiles.has(relativePath);
        const isInsideOutput = candidatePath.startsWith(`${path.resolve(outputRoot)}${path.sep}`);

        if (!isPrivatePlatformFile && isInsideOutput && fs.existsSync(candidatePath) && fs.statSync(candidatePath).isFile()) {
            response.writeHead(200, { 'Content-Type': contentType(relativePath) });
            response.end(fs.readFileSync(candidatePath));
            return;
        }

        response.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
        response.end(fs.readFileSync(path.join(outputRoot, '404.html')));
    });
}

function requestStatus(port, route) {
    return new Promise((resolve, reject) => {
        const request = http.get({ hostname: '127.0.0.1', port, path: route }, response => {
            let body = '';
            response.setEncoding('utf8');
            response.on('data', chunk => { body += chunk; });
            response.on('end', () => resolve({ status: response.statusCode, body }));
        });
        request.on('error', reject);
    });
}

async function verifyLocalResponses(outputRoot, artifactFiles) {
    const server = createArtifactServer(outputRoot);
    await new Promise((resolve, reject) => {
        server.once('error', reject);
        server.listen(0, '127.0.0.1', resolve);
    });

    try {
        const port = server.address().port;
        const publicRoutes = ['/', ...artifactFiles
            .filter(file => !privatePlatformFiles.has(file))
            .map(file => `/${file}`)];

        for (const route of publicRoutes) {
            const response = await requestStatus(port, route);
            if (response.status !== 200) throw new Error(`Expected 200 for ${route}, received ${response.status}`);
        }

        for (const route of privateTestPaths) {
            const response = await requestStatus(port, route);
            if (response.status !== 404) throw new Error(`Expected 404 for ${route}, received ${response.status}`);
            if (!response.body.includes('Page not found')) throw new Error(`404 page missing for ${route}`);
        }
    } finally {
        await new Promise(resolve => server.close(resolve));
    }
}

async function checkArtifact(projectRoot, outputRoot) {
    const manifest = loadManifest(projectRoot);
    verifySourceClassification(projectRoot, manifest);

    const artifactFiles = walkFiles(outputRoot);
    const expectedFiles = [...manifest.publicFiles, ...generatedPlatformFiles].sort();
    if (JSON.stringify(artifactFiles) !== JSON.stringify(expectedFiles)) {
        const expected = new Set(expectedFiles);
        const actual = new Set(artifactFiles);
        const missing = expectedFiles.filter(file => !actual.has(file));
        const unexpected = artifactFiles.filter(file => !expected.has(file));
        throw new Error(`Artifact allowlist mismatch. Missing: ${missing.join(', ') || 'none'}. Unexpected: ${unexpected.join(', ') || 'none'}.`);
    }

    for (const page of publicPages) {
        if (!artifactFiles.includes(page)) throw new Error(`Required public page is missing: ${page}`);
    }

    verifyTextContent(outputRoot, artifactFiles);
    verifyRequiredBehavior(outputRoot);

    const routes = JSON.parse(fs.readFileSync(path.join(outputRoot, '_routes.json'), 'utf8'));
    if (JSON.stringify(routes.include) !== JSON.stringify(manifest.blockedRoutes)) {
        throw new Error('_routes.json does not cover every repository-only path');
    }
    await verifyLocalResponses(outputRoot, artifactFiles);
}

if (require.main === module) {
    const projectRoot = path.resolve(__dirname, '..');
    const outputRoot = path.join(projectRoot, 'dist');
    checkArtifact(projectRoot, outputRoot)
        .then(() => console.log('Public artifact verification passed'))
        .catch(error => {
            console.error(error.message);
            process.exitCode = 1;
        });
}

module.exports = { checkArtifact, loadManifest };
