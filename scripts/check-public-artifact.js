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
const seoPages = publicPages.filter(page => page !== '404.html');
const canonicalUrls = {
    'index.html': `${publicOrigin}/`,
    'services.html': `${publicOrigin}/services.html`,
    'resources.html': `${publicOrigin}/resources.html`,
    'reviews.html': `${publicOrigin}/reviews.html`,
    'contact.html': `${publicOrigin}/contact.html`
};
const organizationId = `${publicOrigin}/#organization`;
const socialImageUrl = `${publicOrigin}/images/og-image.png`;
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
        const attributePattern = /\b(?:href|src|data-image-small|data-image-large)=["']([^"']+)["']/gi;
        while ((match = attributePattern.exec(content))) references.push(match[1]);

        const srcsetPattern = /\bsrcset=["']([^"']+)["']/gi;
        while ((match = srcsetPattern.exec(content))) {
            for (const candidate of match[1].split(',')) {
                const reference = candidate.trim().split(/\s+/)[0];
                if (reference) references.push(reference);
            }
        }

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

function escapeRegExp(value) {
    return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function getSingleTag(content, pattern, description, relativePath) {
    const matches = [...content.matchAll(pattern)];
    if (matches.length !== 1) {
        throw new Error(`${relativePath} must contain exactly one ${description}`);
    }
    return matches[0];
}

function getMetaContent(content, attribute, value, relativePath) {
    const escapedValue = escapeRegExp(value);
    const tag = getSingleTag(
        content,
        new RegExp(`<meta\\b(?=[^>]*\\b${attribute}=["']${escapedValue}["'])[^>]*>`, 'gi'),
        `${attribute}="${value}" meta tag`,
        relativePath
    )[0];
    const contentMatch = tag.match(/\bcontent=(["'])(.*?)\1/i);
    if (!contentMatch || !contentMatch[2].trim()) {
        throw new Error(`${relativePath} has an empty ${attribute}="${value}" meta tag`);
    }
    return contentMatch[2].trim();
}

function collectJsonLd(content, relativePath) {
    const scripts = [...content.matchAll(
        /<script\b(?=[^>]*\btype=["']application\/ld\+json["'])[^>]*>([\s\S]*?)<\/script>/gi
    )];
    if (scripts.length === 0) throw new Error(`${relativePath} is missing JSON-LD`);

    return scripts.flatMap(script => {
        let parsed;
        try {
            parsed = JSON.parse(script[1]);
        } catch (error) {
            throw new Error(`${relativePath} contains invalid JSON-LD: ${error.message}`);
        }
        return Array.isArray(parsed['@graph']) ? parsed['@graph'] : [parsed];
    });
}

function schemaHasType(node, type) {
    return node['@type'] === type || (Array.isArray(node['@type']) && node['@type'].includes(type));
}

function verifyMetadataAndSchema(outputRoot) {
    const titles = new Set();
    const descriptions = new Set();

    for (const relativePath of seoPages) {
        const content = fs.readFileSync(path.join(outputRoot, relativePath), 'utf8');
        const title = getSingleTag(
            content,
            /<title>([^<]+)<\/title>/gi,
            'title',
            relativePath
        )[1].trim();
        const description = getMetaContent(content, 'name', 'description', relativePath);
        const canonicalTag = getSingleTag(
            content,
            /<link\b(?=[^>]*\brel=["']canonical["'])[^>]*>/gi,
            'canonical link',
            relativePath
        )[0];
        const canonicalMatch = canonicalTag.match(/\bhref=["']([^"']+)["']/i);
        const canonical = canonicalMatch && canonicalMatch[1];

        if (!title || titles.has(title)) throw new Error(`${relativePath} has a missing or duplicate title`);
        if (!description || descriptions.has(description)) {
            throw new Error(`${relativePath} has a missing or duplicate meta description`);
        }
        titles.add(title);
        descriptions.add(description);

        if (/<meta\b(?=[^>]*\bname=["']keywords["'])/i.test(content)) {
            throw new Error(`${relativePath} contains obsolete keyword metadata`);
        }
        if (canonical !== canonicalUrls[relativePath]) {
            throw new Error(`${relativePath} has an unexpected canonical URL: ${canonical || 'missing'}`);
        }

        const expectedMeta = [
            ['property', 'og:title', title],
            ['property', 'og:description', description],
            ['property', 'og:type', 'website'],
            ['property', 'og:url', canonical],
            ['property', 'og:site_name', 'E&N Tax & Accounting'],
            ['property', 'og:locale', 'en_US'],
            ['property', 'og:image', socialImageUrl],
            ['property', 'og:image:alt', 'E&N Tax & Accounting — Personal Service, Professional Results'],
            ['name', 'twitter:card', 'summary_large_image'],
            ['name', 'twitter:title', title],
            ['name', 'twitter:description', description],
            ['name', 'twitter:image', socialImageUrl],
            ['name', 'twitter:image:alt', 'E&N Tax & Accounting — Personal Service, Professional Results']
        ];
        for (const [attribute, value, expected] of expectedMeta) {
            const actual = getMetaContent(content, attribute, value, relativePath);
            if (actual !== expected) {
                throw new Error(`${relativePath} has unexpected ${value} content`);
            }
        }

        if (content.includes('info@entaxaccounting.com')) {
            throw new Error(`${relativePath} contains an unapproved contact email`);
        }
        if (!content.includes('mailto:marija@entaxaccounting.com') || !content.includes('tel:+19144830713')) {
            throw new Error(`${relativePath} is missing approved visible contact details`);
        }
        if (/under \$1M|flat[- ]rate|no hourly billing/i.test(content)) {
            throw new Error(`${relativePath} contains an unapproved client-limit or pricing claim`);
        }

        const schemaNodes = collectJsonLd(content, relativePath);
        const serializedSchema = JSON.stringify(schemaNodes);
        if (/AggregateRating|reviewCount|ratingValue/.test(serializedSchema)) {
            throw new Error(`${relativePath} contains self-serving review rating markup`);
        }

        const organization = schemaNodes.find(node => node['@id'] === organizationId);
        if (!organization || !schemaHasType(organization, 'AccountingService')) {
            throw new Error(`${relativePath} is missing the stable AccountingService entity`);
        }
        const expectedOrganizationValues = {
            name: 'E&N Tax & Accounting',
            legalName: 'E&N Tax & Accounting LLC',
            url: `${publicOrigin}/`,
            email: 'marija@entaxaccounting.com',
            telephone: '+1-914-483-0713',
            foundingDate: '2024'
        };
        for (const [property, expected] of Object.entries(expectedOrganizationValues)) {
            if (organization[property] !== expected) {
                throw new Error(`${relativePath} has an unexpected organization ${property}`);
            }
        }
        if (organization.logo?.['@id'] !== `${publicOrigin}/#logo`
            || organization.founder?.['@id'] !== `${publicOrigin}/#founder`
            || organization.contactPoint?.['@id'] !== `${publicOrigin}/#contact-point`) {
            throw new Error(`${relativePath} has incomplete organization entity references`);
        }
        if (JSON.stringify(organization.sameAs) !== JSON.stringify(['https://g.page/r/CQg5gRyJ4mdoEAE/'])) {
            throw new Error(`${relativePath} has unexpected sameAs profiles`);
        }
        const areaNames = organization.areaServed?.map(area => area.name) || [];
        for (const expectedArea of [
            'United States',
            'Westchester County, New York',
            "New York's Hudson Valley",
            'Fairfield County, Connecticut'
        ]) {
            if (!areaNames.includes(expectedArea)) {
                throw new Error(`${relativePath} is missing approved service area: ${expectedArea}`);
            }
        }
        for (const language of ['English', 'Serbian', 'Macedonian']) {
            if (!organization.knowsLanguage?.includes(language)) {
                throw new Error(`${relativePath} is missing approved language: ${language}`);
            }
        }

        const founder = schemaNodes.find(node => node['@id'] === `${publicOrigin}/#founder`);
        if (!founder || founder.name !== 'Marija Sparano' || founder.jobTitle !== 'Founder & CEO') {
            throw new Error(`${relativePath} has incomplete founder schema`);
        }
        const webPageId = relativePath === 'index.html'
            ? `${publicOrigin}/#webpage`
            : `${canonical}#webpage`;
        const webPage = schemaNodes.find(node => node['@id'] === webPageId);
        if (!webPage || !schemaHasType(webPage, 'WebPage')
            || webPage.name !== title
            || webPage.description !== description
            || webPage.about?.['@id'] !== organizationId) {
            throw new Error(`${relativePath} has incomplete or inconsistent WebPage schema`);
        }

        if (relativePath !== 'index.html') {
            const breadcrumbId = `${canonical}#breadcrumb`;
            const breadcrumb = schemaNodes.find(node => node['@id'] === breadcrumbId);
            if (!breadcrumb || !schemaHasType(breadcrumb, 'BreadcrumbList')
                || webPage.breadcrumb?.['@id'] !== breadcrumbId) {
                throw new Error(`${relativePath} has incomplete breadcrumb schema`);
            }
        }

        if (relativePath === 'services.html') {
            const services = schemaNodes.filter(node => schemaHasType(node, 'Service'));
            if (services.length !== 5 || services.some(service => service.provider?.['@id'] !== organizationId)) {
                throw new Error('services.html must define five services provided by the stable entity');
            }
        }

        if (relativePath === 'contact.html') {
            const faq = schemaNodes.find(node => schemaHasType(node, 'FAQPage'));
            if (!faq || faq.mainEntity?.length !== 4) {
                throw new Error('contact.html must define the four visible FAQs');
            }
            for (const question of faq.mainEntity) {
                const answer = question.acceptedAnswer?.text;
                if (!question.name || !answer || !content.includes(question.name) || !content.includes(answer)) {
                    throw new Error('contact.html FAQ schema must match visible questions and answers');
                }
            }
        }
    }

    const resources = fs.readFileSync(path.join(outputRoot, 'resources.html'), 'utf8');
    if (/tax calculators|tax organizers|withholding estimators|rental property calculators|free tax tools/i.test(resources)) {
        throw new Error('resources.html claims resources that are not visible on the page');
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

function verifyPerformanceAndAccessibility(outputRoot, artifactFiles) {
    const baselinePublicImageBytes = 17952699;
    const maximumImageBytes = Math.floor(baselinePublicImageBytes * 0.3);
    const imageFiles = artifactFiles.filter(relativePath => relativePath.startsWith('images/'));
    const imageBytes = imageFiles.reduce((total, relativePath) => (
        total + fs.statSync(path.join(outputRoot, relativePath)).size
    ), 0);

    if (imageBytes > maximumImageBytes) {
        throw new Error(`Public image payload ${imageBytes} bytes does not meet the 70% reduction target`);
    }

    const allowedLegacyImages = new Set(['images/E_N_LOGO.png', 'images/og-image.png']);
    const unexpectedLegacyImages = imageFiles.filter(relativePath => (
        /\.(?:jpe?g|png)$/i.test(relativePath) && !allowedLegacyImages.has(relativePath)
    ));
    if (unexpectedLegacyImages.length > 0) {
        throw new Error(`Unoptimized production images remain: ${unexpectedLegacyImages.join(', ')}`);
    }

    for (const relativePath of publicPages) {
        const content = fs.readFileSync(path.join(outputRoot, relativePath), 'utf8');
        const skipLinks = [...content.matchAll(
            /<a\b(?=[^>]*\bclass=["'][^"']*\bskip-link\b[^"']*["'])(?=[^>]*\bhref=["']#main-content["'])[^>]*>/gi
        )];
        if (skipLinks.length !== 1) {
            throw new Error(`${relativePath} must contain one skip link to #main-content`);
        }
        const mainLandmarks = [...content.matchAll(
            /<main\b(?=[^>]*\bid=["']main-content["'])(?=[^>]*\btabindex=["']-1["'])[^>]*>/gi
        )];
        if (mainLandmarks.length !== 1) {
            throw new Error(`${relativePath} must contain one focusable #main-content landmark`);
        }

        for (const imageTag of content.match(/<img\b[^>]*>/gi) || []) {
            if (!/\bwidth=["']\d+["']/i.test(imageTag) || !/\bheight=["']\d+["']/i.test(imageTag)) {
                throw new Error(`${relativePath} contains an image without intrinsic dimensions`);
            }
        }
    }

    for (const relativePath of seoPages) {
        const content = fs.readFileSync(path.join(outputRoot, relativePath), 'utf8');
        if (!/<nav\b[^>]*\baria-label=["']Primary navigation["']/i.test(content)) {
            throw new Error(`${relativePath} is missing the primary navigation label`);
        }
        if (!/<button\b(?=[^>]*\bclass=["'][^"']*\bmenu-toggle\b)(?=[^>]*\baria-controls=["']navLinks["'])[^>]*>/i.test(content)) {
            throw new Error(`${relativePath} menu toggle must identify navLinks as its controlled region`);
        }
        if (!/\baria-current=["']page["']/i.test(content)) {
            throw new Error(`${relativePath} is missing aria-current on its active navigation link`);
        }
        if (!/<link\b(?=[^>]*\brel=["']preload["'])(?=[^>]*\bas=["']image["'])(?=[^>]*\bfetchpriority=["']high["'])[^>]*>/i.test(content)) {
            throw new Error(`${relativePath} is missing a high-priority hero image preload`);
        }
    }

    const indexHtml = fs.readFileSync(path.join(outputRoot, 'index.html'), 'utf8');
    const indexJs = fs.readFileSync(path.join(outputRoot, 'index.js'), 'utf8');
    const mainJs = fs.readFileSync(path.join(outputRoot, 'main.js'), 'utf8');
    const styles = fs.readFileSync(path.join(outputRoot, 'styles.css'), 'utf8');
    if (!/class=["'][^"']*\bfamily-photo\b[^"']*["'][^>]*\bloading=["']lazy["']/i.test(indexHtml)) {
        throw new Error('Homepage portrait must be lazy-loaded');
    }
    if (!indexHtml.includes('class="hero-toggle"') || !indexJs.includes('prefers-reduced-motion')) {
        throw new Error('Homepage carousel must provide a control and reduced-motion behavior');
    }
    if (!indexJs.includes('IntersectionObserver') || !indexJs.includes('is-image-loaded')) {
        throw new Error('Homepage audience images must be loaded near the viewport');
    }
    if (!mainJs.includes("event.key === 'Escape'")) {
        throw new Error('Mobile navigation must close with Escape');
    }
    if (!styles.includes('@media (prefers-reduced-motion: reduce)')) {
        throw new Error('Shared styles must honor reduced-motion preferences');
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
    if (extension === '.webp') return 'image/webp';
    if (extension === '.png') return 'image/png';
    if (extension === '.jpg' || extension === '.jpeg') return 'image/jpeg';
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
    verifyMetadataAndSchema(outputRoot);
    verifyRequiredBehavior(outputRoot);
    verifyPerformanceAndAccessibility(outputRoot, artifactFiles);

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
