const fs = require('fs');
const path = require('path');
const { checkArtifact, loadManifest } = require('./check-public-artifact');

const projectRoot = path.resolve(__dirname, '..');
const outputRoot = path.join(projectRoot, 'dist');

async function build() {
    const manifest = loadManifest(projectRoot);

    fs.rmSync(outputRoot, { recursive: true, force: true });

    for (const relativePath of manifest.publicFiles) {
        const sourcePath = path.join(projectRoot, relativePath);
        const outputPath = path.join(outputRoot, relativePath);

        if (!fs.statSync(sourcePath).isFile()) {
            throw new Error(`Public source is not a file: ${relativePath}`);
        }

        fs.mkdirSync(path.dirname(outputPath), { recursive: true });
        fs.copyFileSync(sourcePath, outputPath);
    }

    const routes = {
        version: 1,
        include: manifest.blockedRoutes,
        exclude: []
    };
    fs.writeFileSync(
        path.join(outputRoot, '_routes.json'),
        `${JSON.stringify(routes, null, 4)}\n`
    );

    await checkArtifact(projectRoot, outputRoot);
    console.log(`Built and verified ${manifest.publicFiles.length} public files and the Pages route guard in dist/`);
}

build().catch(error => {
    console.error(error.message);
    process.exitCode = 1;
});
