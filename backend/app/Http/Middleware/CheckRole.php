<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Cek apakah role_id user ada dalam daftar roles yang diizinkan
        if (!in_array($user->role_id, $roles)) {
            return response()->json(['message' => 'Forbidden: Anda tidak memiliki akses ke fitur ini'], 403);
        }

        return $next($request);
    }
}
