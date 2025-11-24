'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "e3e35a08bf67249bbb65419756db864a",
"assets/AssetManifest.bin.json": "0b794bb8b4f45ba0b585070def56aa2b",
"assets/AssetManifest.json": "d8b2420623d92f95816e30c4cd2ed5df",
"assets/assets/images/archer.png": "6ade0b6cbcbbfd9f52fce81dd6633804",
"assets/assets/images/armor_leather.png": "e7e436b708efc5076f52ec85afcc4dc8",
"assets/assets/images/athena.png": "9075641fc239661336e37198d8edcfef",
"assets/assets/images/attack.png": "3b0a7affe562ed9bef71044f63cff2e7",
"assets/assets/images/background_home.png": "7305b40239661ce36451f173922f401d",
"assets/assets/images/background_inventory.png": "c41761d3485e2d1e25f1d654d01d94d3",
"assets/assets/images/background_LockerRoom.png": "948ad6f0146789ceda2aff256b805478",
"assets/assets/images/background_login_signup.png": "316865fa996cf79ec40f55ca455b1631",
"assets/assets/images/background_quests.png": "d69fae601e3dcd99e8eb64569bd105e5",
"assets/assets/images/background_scenes.png": "2b917da426be7eed299f9da9994f8125",
"assets/assets/images/battle_axe.png": "993dacf54a9b0009f781bd96ecbc691b",
"assets/assets/images/battle_city.png": "dbd37160e11a054d702eac5b62db25fb",
"assets/assets/images/battle_forest.png": "462b7d08206b6b7daf0ede197526be7d",
"assets/assets/images/battle_ruins.png": "ea265179ca49c1537bf322e9f9e3531a",
"assets/assets/images/battle_snow.png": "dabc9408d30e0972d20609b1bde7b62a",
"assets/assets/images/big_health_potion.png": "ff58d634abd31480b7544d79aa4f3916",
"assets/assets/images/black_texture.png": "e97f032e9936155570576328ea9dc311",
"assets/assets/images/blue_texture.png": "6a199debffe32d599e514fa933e48305",
"assets/assets/images/bow.png": "7693ba5b40dbf619d715d7c572fd903d",
"assets/assets/images/curandeira.png": "b2b72f6fa7c338c72ced241768d8fe2d",
"assets/assets/images/dagger.png": "9e459e89cd2bd7e6637bbe7e02e79546",
"assets/assets/images/dragon.png": "5441084dd6fd14da1bae153dd76f8a56",
"assets/assets/images/druida.png": "94e071013087e5279296d072607945c0",
"assets/assets/images/feiticeira.png": "fe9c124721b491616f01d0feca671862",
"assets/assets/images/fireboll.png": "14e3ecaf29f64dc28cb47809d7c38d28",
"assets/assets/images/fire_dragon.png": "d80a52c06ba90d34513c608bb3c0c626",
"assets/assets/images/goblin.png": "f7673f977a8873596f8d8754eb4438c1",
"assets/assets/images/health_potion.png": "8973cb993b7d039dfb3155d736ab4c68",
"assets/assets/images/knight_hourse.png": "bc0e06bbcb4f05606f1bac394406c7fa",
"assets/assets/images/knight_woman-tiny.png": "7a0e27d16232e95b7df0edb30c1ff12e",
"assets/assets/images/knight_woman.png": "f5ab19c6597016e7bf1a52c781a2ae0a",
"assets/assets/images/ladino.png": "c92fe0a9999cd95e45045944eed9d1f3",
"assets/assets/images/long_sword.png": "dc45cb777ee277aafe5591f80f45f21c",
"assets/assets/images/mage.png": "67bced151554e4a32c19e25df5591694",
"assets/assets/images/magician_woman.png": "1b4f1511d8bbee96a71e51900abe7399",
"assets/assets/images/magic_staff.png": "89272e54c650f0f854298c1fea1c7f47",
"assets/assets/images/monge.png": "d4d60a4ad93f9ce8852a82555e1dd6c8",
"assets/assets/images/monk.png": "cb4a1045ac72a07c6b3d08b006703239",
"assets/assets/images/orc.png": "499ee150570e2f3947b04c0457ec3770",
"assets/assets/images/placeholder.png": "a5bed0ef6d6b9fb59dd30ce42fe806ad",
"assets/assets/images/plate_armor.png": "e967e7ce55296d8bf2b097d878999742",
"assets/assets/images/red_texture.png": "b9cf86269cbb5e821601e17ff82bf2bd",
"assets/assets/images/river_city.png": "8ea3eb7ba2cc5f13300a504f2ee9936f",
"assets/assets/images/ruby_ring.png": "2a5b0c1312298c5eb943f8dc145e161a",
"assets/assets/images/skeleton.png": "35ef56cf98209718db37da18bc3d6445",
"assets/assets/images/small_sword.png": "49517b81e5f1ca2585f672298c6a7e47",
"assets/assets/images/templario.png": "5a2a758752a3c84f2ea94574aca06c60",
"assets/assets/images/warrior.png": "92e23d19b2066f019cf752141318a903",
"assets/assets/images/witch.png": "db166ae9856bf36942005318cb6fecc5",
"assets/assets/images/witch_woman.png": "7fda1088436ca4db9fb7f908e719578b",
"assets/assets/images/wizard_kiwi.png": "1a150d73d8e5024fb533b5ec2f6552af",
"assets/assets/images/wizard_square.png": "0898a249d39689a96e708184fe2f04ee",
"assets/assets/images/wooden_shield.png": "d61ba20c46cd6be5415ea7c306100551",
"assets/assets/images/xama.png": "3a7a954e41f0e10825f4df9b474d8b54",
"assets/assets/sounds/background_music.mp3": "4972d8b9c2f4273e937ff11ceb4e6305",
"assets/assets/sounds/battle_theme.mp3": "eca7522121f2fa0c5f8b97e949afe489",
"assets/assets/sounds/buy_sound.mp3": "0b6fff3fb38d18bbeea7e7279a85eeaa",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "cb19dc8837274a9cc0cd975a183fbbc9",
"assets/NOTICES": "563123d33d042b51f51d0aee993a4789",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "fe02b0ec1cf7dd9854f57c833943bb4c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "9253618ced4a55aa231886a28ccb8cb7",
"/": "9253618ced4a55aa231886a28ccb8cb7",
"main.dart.js": "9df77cfc84b21beaafdd9c81d104b66c",
"manifest.json": "4a0084869360724f5c300083e74c3f70",
"version.json": "1513fb9f12db0ba89bb8f89d9310ffa0"};
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
