const fs = require('fs');
let lines = fs.readFileSync('src/pages/Ibu/PelayananPersalinan.jsx', 'utf8').split('\n');

// Find the index of '{/* ===== RINGKASAN ===== */}'
const ringkasanIndex = lines.findIndex(l => l.includes('===== RINGKASAN ====='));

if (ringkasanIndex !== -1) {
    const tabsCode = `
          {/* Tabs */}
          <div className="w-full border-b border-gray-200 mb-6 flex overflow-x-auto mt-6">
            <TabButton id="ringkasan" label="Ringkasan Melahirkan" />
            <TabButton id="riwayat" label="Riwayat Melahirkan" />
            <TabButton id="keterangan" label="Surat Keterangan Lahir" />
          </div>
`;
    // Insert tabs before ringkasan
    lines.splice(ringkasanIndex, 0, tabsCode);
}

// Fix the end of the file
while (lines[lines.length - 1].trim() === '' || lines[lines.length - 1].trim() === '}') {
    lines.pop();
}

// Remove any remaining closing tags to prevent duplicates
while (lines[lines.length - 1].includes('</div>') || lines[lines.length - 1].includes('</MainLayout>') || lines[lines.length - 1].includes(');')) {
    lines.pop();
}

lines.push('        </div>');
lines.push('    </MainLayout>');
lines.push('  );');
lines.push('}');

fs.writeFileSync('src/pages/Ibu/PelayananPersalinan.jsx', lines.join('\n'));
