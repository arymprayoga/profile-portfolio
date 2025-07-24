<?php

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Route;

// Health Check Route
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'cache' => [
            'redis' => Cache::store('redis')->get('health_check') !== null,
            'memcached' => Cache::store('memcached')->get('health_check') !== null,
        ],
        'static_cache' => file_exists(public_path('static')),
    ]);
});

// Route::statamic('example', 'example-view', [
//    'title' => 'Example'
// ]);
