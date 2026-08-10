// 自毁式 Service Worker —— 清除所有旧缓存后自动注销
self.addEventListener('install', function(event) {
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(keys.map(function(k) {
        return caches.delete(k);
      }));
    }).then(function() {
      // 清除所有缓存后，自动注销自己
      return self.registration.unregister();
    })
  );
  self.clients.claim();
});

// 不拦截任何请求，全部走网络
self.addEventListener('fetch', function(event) {
  event.respondWith(fetch(event.request));
});
