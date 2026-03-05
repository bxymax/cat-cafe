console.log('Starting simple test...');

import('./src/config/env.js').then(({ config }) => {
  console.log('Config loaded:', config);
  console.log('Server should start now...');

  import('./src/app.js').then(({ createApp }) => {
    const app = createApp();
    app.listen(3000, () => {
      console.log('✅ Server started on port 3000');
      setTimeout(() => process.exit(0), 1000);
    });
  });
});
