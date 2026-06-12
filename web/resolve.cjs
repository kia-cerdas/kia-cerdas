const fs = require('fs');
const path = require('path');
const cp = require('child_process');

const root = 'src';

const walk = (dir) => {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach((file) => {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) {
      results = results.concat(walk(file));
    } else if (file.endsWith('.jsx') || file.endsWith('.js')) {
      const content = fs.readFileSync(file, 'utf8');
      if (content.includes('<<<<<<< HEAD')) {
        results.push(file);
      }
    }
  });
  return results;
};

const conflicted = walk(root);
conflicted.forEach((fp) => {
  const normPath = fp.replace(/\\/g, '/');
  console.log('Checking out --theirs for', normPath);
  try {
    cp.execSync(`git checkout --theirs "${normPath}"`);
    cp.execSync(`git add "${normPath}"`);
  } catch (err) {
    console.error(`Failed on ${normPath}:`, err.message);
  }
});
