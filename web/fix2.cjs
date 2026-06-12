const fs = require('fs');
let content = fs.readFileSync('src/pages/Ibu/PelayananPersalinan.jsx', 'utf8');

// Replace the nested handleChange
content = content.replace(
  /const handleChange = \(e, setForm, form\) => \{[\s\S]*?const handleChange = \(e, setForm\) => \{[\s\S]*?\};/m,
  `const handleChange = (e, setForm) => {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === "checkbox" ? checked : value }));
  };`
);

fs.writeFileSync('src/pages/Ibu/PelayananPersalinan.jsx', content);
console.log('Fixed handleChange');
