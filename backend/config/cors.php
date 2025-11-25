<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    /* * PENTING: Saya menambahkan 'storage/*' agar gambar yang diakses 
     * melalui URL storage juga mendapatkan header CORS yang benar.
     */
    'paths' => ['api/*', 'sanctum/csrf-cookie', 'storage/*', 'broadcasting/auth'],

    'allowed_methods' => ['*'],

    /*
     * PENTING: Menggunakan '*' (bintang) mengizinkan akses dari semua domain/port.
     * Ini sangat disarankan untuk tahap Development (localhost:random_port).
     */
    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];