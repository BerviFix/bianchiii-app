'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "55187bc9e7a96f02d006f8fff74be1fa",
"version.json": "88fce18534fb26179e26fa9b3791fd15",
"index.html": "b0de514a1c5ff2b8761fa014577999ac",
"/": "b0de514a1c5ff2b8761fa014577999ac",
"main.dart.js": "d3bdf34c0085af1d66e01189a960d5b2",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "fc00d21321f1291511861df49f80b816",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "caf5ea56ffe29965d3b4b9c781af20f6",
"assets/AssetManifest.json": "5d21455a447f1302ea9b1cc1fbd96c59",
"assets/NOTICES": "5a4623afbda97b2b534dfc5707006f92",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "f0f1d57ce7a3f31b3bd7850050516d79",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "f0f239e9ef4d793034fb05c49e055b6a",
"assets/fonts/MaterialIcons-Regular.otf": "00e01e6b13e4cf00166543bf321acbea",
"assets/assets/video/video-6.mp4": "b74ed492da59d912ce2a7c1fd126d833",
"assets/assets/video/video-7.mp4": "6b6504da5e786ef16bfd2618cb310537",
"assets/assets/video/video-5.mp4": "7a68c477fdd175e8c0a9d6058fe0dceb",
"assets/assets/video/video-4.mp4": "160527f97e08968b1d7305d764a0ccf6",
"assets/assets/video/video-1.mp4": "c6e096f793d5bd93ce8cc919bc4758d2",
"assets/assets/video/video-3.mp4": "1e80e64b4f34505c0ccaa1f0905a23e0",
"assets/assets/video/video-2.mp4": "6defb193642262397661941eeec0d0bc",
"assets/assets/bianchiii-logo.png": "934d0fa534c77d56de38c8c933a9c4d8",
"assets/assets/photos/img-3.jpg": "ba142867034e1e15a58d1f948d2b3282",
"assets/assets/photos/img-2.jpg": "9012cc97d1e3e6309610adc5a95c9ba4",
"assets/assets/photos/img-1.jpg": "5ca42cfd154f1ade6587619091c0a24c",
"assets/assets/photos/img-5.jpg": "92d93d3709e9cf3091e2f58a848f7de6",
"assets/assets/photos/img-4.jpg": "517d54eab2aa6e9cddd35d7c08bb91d2",
"assets/assets/photos/img-6.jpg": "da36f660c74a4dfa5931e1b89c493164",
"assets/assets/photos/img-7.jpg": "5da9240b541a50ad9b14811ad50d82cf",
"assets/assets/photos/img-15.jpg": "b6b18accce88323fa38bfb635526c9b7",
"assets/assets/photos/img-14.jpg": "c4694ac2ad9200e3c5fe35066d4400a8",
"assets/assets/photos/img-9.jpg": "ad95cfb51a3b7714d8a43daefddd314a",
"assets/assets/photos/img-8.jpg": "571390eae4c28a1edf870f0d14d05033",
"assets/assets/photos/img-13.jpg": "498c97513068e17cbca8c9fc03372f0a",
"assets/assets/photos/img-12.jpg": "b5585e3f860cbd33d0e1853e14cbda10",
"assets/assets/photos/img-10.jpg": "751ac4b5b87a5ada8694f530d3dc3c82",
"assets/assets/photos/img-11.jpg": "5866e132211349d5a158664eee0564a3",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
