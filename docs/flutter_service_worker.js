'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "c44c53ea5d2ca92afdf56132bd4ba7d0",
"index.html": "f587a4e592d3fbdd8d5fd061c4f96d14",
"/": "f587a4e592d3fbdd8d5fd061c4f96d14",
"main.dart.js": "a73397e1cd2976a5446b69b6a38d4b00",
"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"favicon.png": "f870fc72d974535c6eec58799acadbfa",
"icons/icon.png": "f870fc72d974535c6eec58799acadbfa",
"manifest.json": "add8790b913b659ed9a9cd47e238dd7f",
"assets/AssetManifest.json": "9e929f17a71d39f73ba8c3514bb5756e",
"assets/NOTICES": "d80b2e77cee7ad9b5f2ea8b248330e7e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "d9e4a878662f15188fa328979e37ef07",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/packages/record_web/assets/js/record.worklet.js": "356bcfeddb8a625e3e2ba43ddf1cc13e",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/AssetManifest.bin": "f66dad73e649a74311363272e8738fd5",
"assets/fonts/MaterialIcons-Regular.otf": "5a6dc17c173388d6a900ac5211a9423b",
"assets/assets/nephis_courage_2_1.png": "53b4efba7ce7f297cad9429db89aed9f",
"assets/assets/nephis_courage_2_2.png": "a16f81e87900a2fb00c26084c857cbd5",
"assets/assets/nephis_courage_2_3.png": "a16f81e87900a2fb00c26084c857cbd5",
"assets/assets/nephis_courage_2_7.png": "13e920fba762af6df5e359bde46acef7",
"assets/assets/nephis_courage_2_6.png": "8cb957aecbf14d8002227a7e3e886112",
"assets/assets/nephis_courage_2_4.png": "f460dc71d9b4c6d12adf06f5c72ab36a",
"assets/assets/nephis_courage_2_5.png": "8cb957aecbf14d8002227a7e3e886112",
"assets/assets/nephis_courage_1_1.png": "b07cb43c414e987a853ce5c2c1fc86b8",
"assets/assets/nephis_courage_1_3.png": "d60ff16fa93b20dd9ae4803a77dfdedc",
"assets/assets/nephis_courage_1_2.png": "7b528ee283b432ec7bbd8bce7c6df1cd",
"assets/assets/nephis_courage_1_6.png": "13e920fba762af6df5e359bde46acef7",
"assets/assets/nephis_courage_1_7.png": "8cb957aecbf14d8002227a7e3e886112",
"assets/assets/nephis_courage_1_goal.png": "f6c6e7fed34bc4b0a3574620ca285bd4",
"assets/assets/nephis_courage_1_5.png": "13e920fba762af6df5e359bde46acef7",
"assets/assets/nephis_courage_1_4.png": "d60ff16fa93b20dd9ae4803a77dfdedc",
"assets/assets/nephis_courage_1_8.png": "8cb957aecbf14d8002227a7e3e886112",
"assets/assets/confetti.gif": "76dede6e501fc18d4119ad94ad140835",
"assets/assets/nephis_courage_2_8.png": "13e920fba762af6df5e359bde46acef7",
"assets/assets/nephis_courage_2_character.png": "f0ca12ee17d2fa402143b65f724411e4",
"assets/assets/nephis_courage_1_character.png": "fe3009ecc82417a1f242940655438cb1",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "4124c42a73efa7eb886d3400a1ed7a06",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "f87e541501c96012c252942b6b75d1ea",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "64edb91684bdb3b879812ba2e48dd487",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
