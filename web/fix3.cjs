const fs = require('fs');
let content = fs.readFileSync('src/pages/Ibu/PelayananPersalinan.jsx', 'utf8');

// The code we want to remove
const oldCodeRegex = /const TabButton = \(\{ id, label \}\) => \([\s\S]*?<\/button>\s*\);/;

content = content.replace(oldCodeRegex, '');

const newTabButton = `
const TabButton = ({ id, label, activeTab, setActiveTab }) => (
  <button onClick={() => setActiveTab(id)}
    className={\`py-3 px-6 text-sm font-medium border-b-2 transition-colors \${activeTab === id
      ? "border-indigo-600 text-indigo-600 bg-indigo-50"
      : "border-transparent text-gray-500 hover:text-gray-700"}\`}>
    {label}
  </button>
);
`;

content = content.replace('// KOMPONEN DETAIL ITEM', newTabButton + '\n// KOMPONEN DETAIL ITEM');

fs.writeFileSync('src/pages/Ibu/PelayananPersalinan.jsx', content);
console.log('Moved TabButton');
